#!/usr/bin/env ruby

require 'open3'
require 'yaml'
require 'json'
require 'time'

# Array of Ruby versions to test
RUBY_VERSIONS = %w[2.5 2.6 2.7 3.0 3.1 3.2 3.4].freeze

# Public tasks that can be invoked with `bake <task_name>`

# @parameter force [Boolean] Whether to force re-run the benchmarks even if results exist
# @parameter versions [Array(String)] Specific Ruby versions to benchmark.
def benchmark(force: false, versions: RUBY_VERSIONS)
	puts "# Fiber vs Thread Allocation Benchmark"
	
	versions.each do |v|
		run_benchmark_for_version(v, force: force)
	end
end

def results
	loaded_results = load_results
	
	if loaded_results.empty?
		puts "No results found. Run 'bake benchmark' first."
		exit 1
	end
	
	generate_markdown_tables(loaded_results)
end

private

def parse_benchmark_output(fiber_output, thread_output)
	# Parse the flat YAML outputs from fiber and thread benchmarks
	begin
		fiber_data = YAML.load(fiber_output) if fiber_output && !fiber_output.empty?
		thread_data = YAML.load(thread_output) if thread_output && !thread_output.empty?
		
		# Convert the flat data to the format expected by the rest of the script
		parsed = {}
		
		if fiber_data
			parsed[:fiber_time] = fiber_data['time_ms']
			parsed[:fiber_creation_rate] = fiber_data['creation_rate']
			parsed[:fiber_switch_rate] = fiber_data['switch_rate']
			parsed[:fiber_memory_used] = fiber_data['memory_used_bytes']
			parsed[:fiber_memory_per_unit] = fiber_data['memory_per_fiber_bytes']
		end
		
		if thread_data
			parsed[:thread_time] = thread_data['time_ms']
			parsed[:thread_creation_rate] = thread_data['creation_rate']
			parsed[:thread_switch_rate] = thread_data['switch_rate']
			parsed[:thread_memory_used] = thread_data['memory_used_bytes']
			parsed[:thread_memory_per_unit] = thread_data['memory_per_thread_bytes']
		end
		
		# Calculate performance ratio if we have both times
		if parsed[:fiber_time] && parsed[:thread_time] && parsed[:fiber_time] > 0
			parsed[:ratio] = (parsed[:thread_time] / parsed[:fiber_time]).round(1)
		end
		
		return parsed
	rescue => e
		puts "Error parsing YAML: #{e.message}"
		puts "Fiber output: #{fiber_output}"
		puts "Thread output: #{thread_output}"
		return {}
	end
end

def run_benchmark_for_version(version, force: false)
	results_dir = 'results'
	version_dir = File.join(results_dir, "ruby-#{version}")
	fiber_file = File.join(version_dir, 'fibers.yaml')
	thread_file = File.join(version_dir, 'threads.yaml')
	
	# Skip if files exist and not forcing regeneration
	if !force && File.exist?(fiber_file) && File.exist?(thread_file)
		puts "Skipping Ruby #{version} (results already exist)"
		return
	end
	
	puts ""
	puts "## Testing Ruby #{version}...", nil
	
	# Ensure directory exists
	Dir.mkdir(results_dir) unless Dir.exist?(results_dir)
	Dir.mkdir(version_dir) unless Dir.exist?(version_dir)
	
	version_results = {
		'platform' => nil,
		'memory_usage' => {},
		'context_switching' => {}
	}
	
	# Test 1: Memory usage comparison with 2 context switches
	puts "Memory usage test (10000 fibers/threads, 2 switches each):"
	
	# Run fiber benchmark
	fiber_command = [
		"docker", "run", "--rm",
		"-v", "#{Dir.pwd}/support.rb:/support.rb:ro",
		"-v", "#{Dir.pwd}/fibers.rb:/fibers.rb:ro",
		"ruby:#{version}", "ruby", "/fibers.rb", "10000", "2"
	]
	
	fiber_stdout, fiber_status = Open3.capture2(*fiber_command)
	
	# Run thread benchmark
	thread_command = [
		"docker", "run", "--rm",
		"-v", "#{Dir.pwd}/support.rb:/support.rb:ro",
		"-v", "#{Dir.pwd}/threads.rb:/threads.rb:ro",
		"ruby:#{version}", "ruby", "/threads.rb", "10000", "2"
	]
	
	thread_stdout, thread_status = Open3.capture2(*thread_command)
	
	if fiber_status.success? && thread_status.success?
		# Parse both outputs
		memory_data = parse_benchmark_output(fiber_stdout, thread_stdout)
		version_results['memory_usage'] = {
			'fiber_time' => memory_data[:fiber_time],
			'thread_time' => memory_data[:thread_time],
			'ratio' => memory_data[:ratio],
			'fiber_creation_rate' => memory_data[:fiber_creation_rate],
			'thread_creation_rate' => memory_data[:thread_creation_rate],
			'fiber_switch_rate' => memory_data[:fiber_switch_rate],
			'thread_switch_rate' => memory_data[:thread_switch_rate],
			'fiber_memory_used' => memory_data[:fiber_memory_used],
			'fiber_memory_per_unit' => memory_data[:fiber_memory_per_unit],
			'thread_memory_used' => memory_data[:thread_memory_used],
			'thread_memory_per_unit' => memory_data[:thread_memory_per_unit]
		}
		
		# Extract platform info from fiber output
		if fiber_stdout =~ /platform: (.+)/
			version_results['platform'] = $1.strip
		end
	else
		puts "Failed to run memory benchmark for Ruby #{version}"
		version_results['memory_usage'] = { 'error' => 'Command failed' }
	end
	
	# Test 2: Context switching performance with 10000 switches on 2 workers
	puts "Context switching test (2 fibers/threads, 10000 switches each):"
	
	# Run fiber benchmark
	fiber_command = [
		"docker", "run", "--rm",
		"-v", "#{Dir.pwd}/support.rb:/support.rb:ro",
		"-v", "#{Dir.pwd}/fibers.rb:/fibers.rb:ro",
		"ruby:#{version}", "ruby", "/fibers.rb", "2", "10000"
	]
	
	fiber_stdout, fiber_status = Open3.capture2(*fiber_command)
	
	# Run thread benchmark
	thread_command = [
		"docker", "run", "--rm",
		"-v", "#{Dir.pwd}/support.rb:/support.rb:ro",
		"-v", "#{Dir.pwd}/threads.rb:/threads.rb:ro",
		"ruby:#{version}", "ruby", "/threads.rb", "2", "10000"
	]
	
	thread_stdout, thread_status = Open3.capture2(*thread_command)
	
	if fiber_status.success? && thread_status.success?
		switching_data = parse_benchmark_output(fiber_stdout, thread_stdout)
		version_results['context_switching'] = {
			'fiber_time' => switching_data[:fiber_time],
			'thread_time' => switching_data[:thread_time],
			'ratio' => switching_data[:ratio],
			'fiber_creation_rate' => switching_data[:fiber_creation_rate],
			'thread_creation_rate' => switching_data[:thread_creation_rate],
			'fiber_switch_rate' => switching_data[:fiber_switch_rate],
			'thread_switch_rate' => switching_data[:thread_switch_rate]
		}
	else
		puts "Failed to run context switching benchmark for Ruby #{version}"
		version_results['context_switching'] = { 'error' => 'Command failed' }
	end
	
	# Save separate files for fibers and threads
	timestamp = Time.now.iso8601
	
	fiber_results = {
		'timestamp' => timestamp,
		'ruby_version' => version,
		'platform' => version_results['platform'],
		'memory_usage' => {
			'time_ms' => version_results['memory_usage']['fiber_time'],
			'creation_rate' => version_results['memory_usage']['fiber_creation_rate'],
			'switch_rate' => version_results['memory_usage']['fiber_switch_rate'],
			'memory_used_bytes' => version_results['memory_usage']['fiber_memory_used'],
			'memory_per_unit_bytes' => version_results['memory_usage']['fiber_memory_per_unit']
		},
		'context_switching' => {
			'time_ms' => version_results['context_switching']['fiber_time'],
			'creation_rate' => version_results['context_switching']['fiber_creation_rate'],
			'switch_rate' => version_results['context_switching']['fiber_switch_rate']
		}
	}
	
	thread_results = {
		'timestamp' => timestamp,
		'ruby_version' => version,
		'platform' => version_results['platform'],
		'memory_usage' => {
			'time_ms' => version_results['memory_usage']['thread_time'],
			'creation_rate' => version_results['memory_usage']['thread_creation_rate'],
			'switch_rate' => version_results['memory_usage']['thread_switch_rate'],
			'memory_used_bytes' => version_results['memory_usage']['thread_memory_used'],
			'memory_per_unit_bytes' => version_results['memory_usage']['thread_memory_per_unit']
		},
		'context_switching' => {
			'time_ms' => version_results['context_switching']['thread_time'],
			'creation_rate' => version_results['context_switching']['thread_creation_rate'],
			'switch_rate' => version_results['context_switching']['thread_switch_rate']
		}
	}
	
	File.write(fiber_file, YAML.dump(fiber_results))
	File.write(thread_file, YAML.dump(thread_results))
	
	puts "Results saved for Ruby #{version}"
end

def load_results
	results = {}
	results_dir = 'results'
	
	return results unless Dir.exist?(results_dir)
	
	RUBY_VERSIONS.each do |version|
		version_dir = File.join(results_dir, "ruby-#{version}")
		fiber_file = File.join(version_dir, 'fibers.yaml')
		thread_file = File.join(version_dir, 'threads.yaml')
		
		if File.exist?(fiber_file) && File.exist?(thread_file)
			fiber_data = YAML.load_file(fiber_file)
			thread_data = YAML.load_file(thread_file)
			
			# Reconstruct the combined format for table generation
			results[version] = {
				'platform' => fiber_data['platform'],
				'memory_usage' => {
					'fiber_time' => fiber_data['memory_usage']['time_ms'],
					'thread_time' => thread_data['memory_usage']['time_ms'],
					'ratio' => thread_data['memory_usage']['time_ms'] / fiber_data['memory_usage']['time_ms'],
					'fiber_creation_rate' => fiber_data['memory_usage']['creation_rate'],
					'thread_creation_rate' => thread_data['memory_usage']['creation_rate'],
					'fiber_switch_rate' => fiber_data['memory_usage']['switch_rate'],
					'thread_switch_rate' => thread_data['memory_usage']['switch_rate'],
					'fiber_memory_used' => fiber_data['memory_usage']['memory_used_bytes'],
					'fiber_memory_per_unit' => fiber_data['memory_usage']['memory_per_unit_bytes'],
					'thread_memory_used' => thread_data['memory_usage']['memory_used_bytes'],
					'thread_memory_per_unit' => thread_data['memory_usage']['memory_per_unit_bytes']
				},
				'context_switching' => {
					'fiber_time' => fiber_data['context_switching']['time_ms'],
					'thread_time' => thread_data['context_switching']['time_ms'],
					'ratio' => thread_data['context_switching']['time_ms'] / fiber_data['context_switching']['time_ms'],
					'fiber_creation_rate' => fiber_data['context_switching']['creation_rate'],
					'thread_creation_rate' => thread_data['context_switching']['creation_rate'],
					'fiber_switch_rate' => fiber_data['context_switching']['switch_rate'],
					'thread_switch_rate' => thread_data['context_switching']['switch_rate']
				}
			}
		end
	end
	
	results
end

def generate_markdown_tables(results)
	puts "\n### Performance Summary\n"
	puts "| Ruby Version | Allocation Ratio | Fiber Alloc (μs) | Thread Alloc (μs) | Switch Ratio | Fiber Switch (μs) | Thread Switch (μs) |"
	puts "|--------------|------------------|-------------------|-------------------|--------------|-------------------|--------------------| "

	results.each do |version, data|
		allocation_ratio = data['memory_usage']['ratio'] || 'N/A'
		switch_ratio = data['context_switching']['ratio'] || 'N/A'
		fiber_alloc_time = data['memory_usage']['fiber_time'] || 'N/A'
		thread_alloc_time = data['memory_usage']['thread_time'] || 'N/A'
		fiber_switch_time = data['context_switching']['fiber_time'] || 'N/A'
		thread_switch_time = data['context_switching']['thread_time'] || 'N/A'
		
		# Calculate time per allocation in microseconds
		# Memory usage test uses 10,000 fibers/threads
		fiber_alloc_per_us = fiber_alloc_time.is_a?(Numeric) ? (fiber_alloc_time * 1000.0 / 10000.0) : 'N/A'
		thread_alloc_per_us = thread_alloc_time.is_a?(Numeric) ? (thread_alloc_time * 1000.0 / 10000.0) : 'N/A'
		
		# Calculate time per context switch in microseconds
		# Context switching test uses 2 fibers/threads with 10,000 switches each = 20,000 total switches
		fiber_switch_per_us = fiber_switch_time.is_a?(Numeric) ? (fiber_switch_time * 1000.0 / 20000.0) : 'N/A'
		thread_switch_per_us = thread_switch_time.is_a?(Numeric) ? (thread_switch_time * 1000.0 / 20000.0) : 'N/A'
		
		# Format times to appropriate decimal places
		fiber_alloc_formatted = fiber_alloc_per_us.is_a?(Numeric) ? "%.3f" % fiber_alloc_per_us : fiber_alloc_per_us
		thread_alloc_formatted = thread_alloc_per_us.is_a?(Numeric) ? "%.3f" % thread_alloc_per_us : thread_alloc_per_us
		fiber_switch_formatted = fiber_switch_per_us.is_a?(Numeric) ? "%.3f" % fiber_switch_per_us : fiber_switch_per_us
		thread_switch_formatted = thread_switch_per_us.is_a?(Numeric) ? "%.3f" % thread_switch_per_us : thread_switch_per_us
		allocation_ratio_formatted = allocation_ratio.is_a?(Numeric) ? "%.1fx" % allocation_ratio : allocation_ratio
		switch_ratio_formatted = switch_ratio.is_a?(Numeric) ? "%.1fx" % switch_ratio : switch_ratio
		
		puts "| #{version.ljust(12)} | #{allocation_ratio_formatted.ljust(15)} | #{fiber_alloc_formatted.ljust(17)} | #{thread_alloc_formatted.ljust(17)} | #{switch_ratio_formatted.ljust(12)} | #{fiber_switch_formatted.ljust(17)} | #{thread_switch_formatted.ljust(18)} |"
	end

	puts "\n*Allocation times are per individual fiber/thread (10,000 total allocations)*"
	puts "*Context switch times are per individual switch (2 workers × 10,000 switches = 20,000 total)*"

	puts "\n### Context Switching Performance\n"
	puts "| Ruby Version | Fiber Switches/sec | Thread Switches/sec | Performance Ratio |"
	puts "|--------------|-------------------|--------------------|--------------------|"

	results.each do |version, data|
		switch_ratio = data['context_switching']['ratio'] || 'N/A'
		fiber_switch_rate = data['context_switching']['fiber_switch_rate'] || 'N/A'
		thread_switch_rate = data['context_switching']['thread_switch_rate'] || 'N/A'
		
		# Format switch rates with commas
		fiber_rate_formatted = fiber_switch_rate.is_a?(Numeric) ? fiber_switch_rate.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse : fiber_switch_rate
		thread_rate_formatted = thread_switch_rate.is_a?(Numeric) ? thread_switch_rate.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse : thread_switch_rate
		switch_ratio_formatted = switch_ratio.is_a?(Numeric) ? "%.1fx" % switch_ratio : switch_ratio
		
		puts "| #{version.ljust(12)} | #{fiber_rate_formatted.ljust(17)} | #{thread_rate_formatted.ljust(18)} | #{switch_ratio_formatted.ljust(17)} |"
	end

	puts "\n### Memory Usage Per Unit\n"
	puts "| Ruby Version | Fiber Memory (bytes) | Thread Memory (bytes) | Fiber Total (MB) | Thread Total (MB) |"
	puts "|--------------|---------------------|----------------------|------------------|-------------------|"

	results.each do |version, data|
		fiber_mem_per_unit = data['memory_usage']['fiber_memory_per_unit'] || 'N/A'
		thread_mem_per_unit = data['memory_usage']['thread_memory_per_unit'] || 'N/A'
		fiber_mem_total = data['memory_usage']['fiber_memory_used'] || 'N/A'
		thread_mem_total = data['memory_usage']['thread_memory_used'] || 'N/A'
		
		# Convert total bytes to MB and format
		fiber_total_mb = fiber_mem_total.is_a?(Numeric) ? "%.1f" % (fiber_mem_total / 1024.0 / 1024.0) : fiber_mem_total
		thread_total_mb = thread_mem_total.is_a?(Numeric) ? "%.1f" % (thread_mem_total / 1024.0 / 1024.0) : thread_mem_total
		
		# Format per-unit memory with commas
		fiber_per_formatted = fiber_mem_per_unit.is_a?(Numeric) ? fiber_mem_per_unit.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse : fiber_mem_per_unit
		thread_per_formatted = thread_mem_per_unit.is_a?(Numeric) ? thread_mem_per_unit.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse : thread_mem_per_unit
		
		puts "| #{version.ljust(12)} | #{fiber_per_formatted.ljust(19)} | #{thread_per_formatted.ljust(20)} | #{fiber_total_mb.ljust(16)} | #{thread_total_mb.ljust(17)} |"
	end
end