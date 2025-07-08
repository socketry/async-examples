require 'benchmark'
require 'optparse'

ITERATIONS = 1000

# Memory profiling utilities
def get_memory_usage
  # Try to get RSS from /proc/self/status (Linux)
  if File.exist?('/proc/self/status')
    status = File.read('/proc/self/status')
    if match = status.match(/VmRSS:\s+(\d+)\s+kB/)
      return match[1].to_i * 1024 # Convert to bytes
    end
  end
  
  # Fallback: estimate from GC stats (less accurate but portable)
  gc_stat = GC.stat
  # Rough estimate: heap_live_slots * average_object_size
  estimated_bytes = gc_stat[:heap_live_slots] * 40 # Rough average Ruby object size
  return estimated_bytes
end

def get_gc_stats
  GC.stat.slice(:heap_live_slots, :heap_free_slots, :total_allocated_objects, :heap_allocated_pages)
end

def force_gc_and_measure
  # Force garbage collection to get clean measurements
  3.times { GC.start }
  sleep 0.01 # Small delay to ensure GC is complete
  {
    memory_bytes: get_memory_usage,
    gc_stats: get_gc_stats
  }
end

def parse_common_options
  options = { count: ITERATIONS, switches: 1 }
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    
    opts.on("--switches [SWITCHES]", Integer, "Number of context switches (default: 1)") do |switches|
      options[:switches] = switches || 1
    end
    
    opts.on("--count COUNT", Integer, "Number of fibers/threads to allocate (default: #{ITERATIONS})") do |count|
      options[:count] = count
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!
  
  options
end

def output_common_info(options)
  # Send progress info to stderr, structured data to stdout
  $stderr.puts "Benchmarking Ruby #{RUBY_VERSION} on #{RUBY_PLATFORM}"
  $stderr.puts "Options: #{options.inspect}"
  
  # Output basic info to YAML
  puts "ruby_version: #{RUBY_VERSION}"
  puts "platform: #{RUBY_PLATFORM}"
  puts "options:"
  options.each do |key, value|
    puts "  #{key}: #{value}"
  end
end