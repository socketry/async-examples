#!/usr/bin/env ruby

require_relative 'support'

def benchmark_threads(count, switches = 1)
  switch_count = 0
  threads = []
  
  # Measure memory before allocation
  $stderr.puts "Measuring thread memory usage..."
  before_memory = force_gc_and_measure
  
  time = Benchmark.realtime do
    count.times do
      threads << Thread.new {
        switches.times do
          switch_count += 1
          Thread.pass
        end
      }
    end
    
    # Wait for all threads to complete
    threads.each{|thread| thread.join}
  end
  
  # Measure memory after allocation (but before cleanup)
  after_memory = force_gc_and_measure
  memory_used = after_memory[:memory_bytes] - before_memory[:memory_bytes]
  memory_per_thread = count > 0 ? memory_used / count : 0
  
  # Calculate rates
  creations_per_second = count / time
  switches_per_second = switch_count / time
  
  # Output YAML directly
  puts "count: #{count}"
  puts "switches: #{switches}"
  puts "total_switches: #{switch_count}"
  puts "time_ms: #{(time * 1000).round(3)}"
  puts "creation_rate: #{creations_per_second.round(0)}"
  puts "switch_rate: #{switches_per_second.round(0)}"
  puts "memory_used_bytes: #{memory_used}"
  puts "memory_per_thread_bytes: #{memory_per_thread.round(0)}"
  puts "memory_before: #{before_memory[:memory_bytes]}"
  puts "memory_after: #{after_memory[:memory_bytes]}"
  puts "gc_objects_before: #{before_memory[:gc_stats][:heap_live_slots]}"
  puts "gc_objects_after: #{after_memory[:gc_stats][:heap_live_slots]}"
  
  time
end

# Main execution
# Parse simple ARGV: count switches
count = (ARGV[0] || ITERATIONS).to_i
switches = (ARGV[1] || 1).to_i

# Send progress info to stderr, structured data to stdout
$stderr.puts "Benchmarking Ruby #{RUBY_VERSION} on #{RUBY_PLATFORM}"
$stderr.puts "Running thread benchmark with #{count} threads, #{switches} switches each..."

# Output basic info to YAML
puts "ruby_version: #{RUBY_VERSION}"
puts "platform: #{RUBY_PLATFORM}"
puts "count: #{count}"
puts "switches: #{switches}"

# Warmup
$stderr.puts "Warming up..."
benchmark_threads(10, 1)
sleep 1

# Run benchmark
$stderr.puts "Running thread benchmark..."
thread_time = benchmark_threads(count, switches)
$stderr.puts "Thread time: #{(thread_time * 1000).round(2)}ms"