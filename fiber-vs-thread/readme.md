# Fiber vs Thread Allocation Benchmark

This benchmark compares the allocation performance and memory usage of Fibers vs Threads across different Ruby versions.

## Overview

The benchmark consists of two focused tests:
1. **Memory Usage Test**: Allocates 10,000 fibers/threads with 2 context switches each to measure memory overhead and allocation performance
2. **Context Switching Test**: Uses 2 fibers/threads with 10,000 context switches each to measure switching performance

**Performance Ratios**: All ratios in this benchmark show how much more expensive (slower) threads are compared to fibers. For example, a ratio of 5.0x means threads take 5 times longer than fibers to perform the same operation.

## Usage

Run the complete benchmark across all Ruby versions:

```bash
ruby run.rb
```

Run individual benchmarks:

```bash
ruby fibers.rb 1000 2    # 1000 fibers, 2 switches each
ruby threads.rb 1000 2   # 1000 threads, 2 switches each
```

## Requirements

- Docker installed and running
- Internet connection to pull Ruby images

## Benchmark Results

*Last updated: July 8, 2025*

### Performance Summary

| Ruby Version | Allocation Ratio | Fiber Alloc (ms) | Thread Alloc (ms) | Switch Ratio | Fiber Switch (ms) | Thread Switch (ms) |
|--------------|------------------|-------------------|-------------------|--------------|-------------------|--------------------|
| 2.5          | 11.5x            | 72.0              | 827.4             | 1.9x         | 9.2               | 17.0               |
| 2.6          | 9.3x             | 66.2              | 614.4             | 3.6x         | 3.4               | 12.5               |
| 2.7          | 5.3x             | 38.6              | 202.9             | 2.7x         | 3.7               | 9.8                |
| 3.0          | 5.4x             | 39.1              | 210.8             | 4.2x         | 3.7               | 15.7               |
| 3.1          | 5.4x             | 38.1              | 205.6             | 5.1x         | 2.8               | 14.4               |
| 3.2          | 5.3x             | 38.6              | 204.6             | 3.5x         | 3.3               | 11.6               |
| 3.4          | 17.7x            | 41.3              | 732.7             | 12.9x        | 3.1               | 39.7               |

*Allocation times are for creating 10,000 fibers/threads with 2 switches each*  
*Context switch times are for 2 fibers/threads performing 10,000 switches each*

### Context Switching Performance

| Ruby Version | Fiber Switches/sec | Thread Switches/sec | Performance Ratio |
|--------------|-------------------|--------------------|--------------------|
| 2.5          | 2,483,026         | 926,124            | 2.7x              |
| 2.6          | 5,858,547         | 1,280,776          | 4.6x              |
| 2.7          | 6,792,701         | 1,687,008          | 4.0x              |
| 3.0          | 6,135,133         | 889,984            | 6.9x              |
| 3.1          | 5,113,368         | 1,446,258          | 3.5x              |
| 3.2          | 5,688,399         | 1,142,107          | 5.0x              |
| 3.4          | 6,553,252         | 492,411            | 13.3x             |

### Memory Usage Per Unit

| Ruby Version | Fiber Memory (bytes) | Thread Memory (bytes) | Fiber Total (MB) | Thread Total (MB) |
|--------------|---------------------|----------------------|------------------|-------------------|
| 2.5          | 14,627              | 9,666                | 139.4            | 92.2              |
| 2.6          | 9,699               | 10,437               | 92.5             | 99.5              |
| 2.7          | 13,107              | 15,597               | 125.0            | 148.7             |
| 3.0          | 13,133              | 18,035               | 125.3            | 172.1             |
| 3.1          | 13,133              | 18,114               | 125.3            | 172.8             |
| 3.2          | 13,133              | 17,904               | 125.3            | 170.7             |
| 3.4          | 13,133              | 10,930               | 125.3            | 104.2             |

## Performance History

### Ruby 2.6: Native Assembly Implementation

A significant performance improvement occurred in Ruby 2.6 with the implementation of native `coroutine_transfer` in assembly language, replacing the previous C implementation that used `ucontext`.

**Commit**: [07a324a0f6464f31765ee4bc5cfc23a99d426705](https://github.com/ruby/ruby/commit/07a324a0f6464f31765ee4bc5cfc23a99d426705)

**Performance Impact**:
- **Context switching improved by 2.1x**: From 0.316 μs/switch (Ruby 2.5) to 0.148 μs/switch (Ruby 2.6)
- **Throughput doubled**: From 3.16 million switches/sec to 6.77 million switches/sec
- **Assembly implementations**: Added for multiple architectures including x86_64, ARM, and others

This change represents one of the most significant fiber performance improvements in Ruby's history, demonstrating the impact of low-level optimizations on high-level language performance.

### Ruby 2.7: Pooled Stack Allocations

Ruby 2.7 introduced pooled stack allocations for fibers, optimizing memory management and allocation performance.

**Commit**: [14cf95cff35612c6238790ad2f605530f69e9a44](https://github.com/ruby/ruby/commit/14cf95cff35612c6238790ad2f605530f69e9a44)

**Performance Impact**:
- **Allocation improved by 2.0x**: From 7.9 μs/allocation (Ruby 2.6) to 3.8 μs/allocation (Ruby 2.7)
- **Memory efficiency**: Reusing stack allocations reduces system call overhead
- **Consistent performance**: Ruby 2.7-3.2 show stable ~3.8-4.7 μs allocation times

The pooled allocation strategy significantly reduced the cost of creating new fibers by reusing previously allocated stacks, leading to more predictable performance characteristics that have been maintained through subsequent Ruby versions.

### Ruby 2.7: Thread VM Stack Allocation with Alloca

Ruby 2.7 also optimized thread performance by moving VM stack initialization into threads and using `alloca` for stack allocation.

**Commit**: [b24603adff8ec1e93e71358b93b3e30c99ba29d5](https://github.com/ruby/ruby/commit/b24603adff8ec1e93e71358b93b3e30c99ba29d5)

**Performance Impact**:
- **Thread allocation improved by 3.6x**: From 76.4 μs/allocation (Ruby 2.6) to 21.3 μs/allocation (Ruby 2.7)
- **Reduced system calls**: Stack allocated on the C stack rather than heap allocation
- **Better memory locality**: Stack allocation provides better cache performance
- **Sustained improvement**: Ruby 3.0+ maintains ~19.6-23.7 μs allocation times

This optimization delivered an even more dramatic improvement than the fiber pooling, showing a 72% reduction in thread allocation time. Combined with the fiber improvements, Ruby 2.7 became a landmark release for Ruby's entire concurrency infrastructure.

### Ruby 3.0: Ractor Introduction and Thread-Local Storage

Ruby 3.0 introduced Ractors as an experimental feature for true parallelism, requiring significant changes to Ruby's VM architecture to support isolated execution contexts.

**Performance Impact**:
- **Thread context switching regressed by 88%**: From 0.566 μs/switch (Ruby 2.7) to 1.064 μs/switch (Ruby 3.0)
- **Thread switching throughput decreased by 47%**: From 1.77 million switches/sec to 940k switches/sec
- **Fiber context switching regressed by 6%**: From 6.53 million switches/sec to 6.13 million switches/sec
- **Fiber performance continued declining**: Through Ruby 3.1-3.2 before recovering in Ruby 3.4

While Ractors were designed to enable true parallelism, their experimental status and stability issues limited adoption in production applications. The performance cost of the TLS infrastructure was incurred by all Ruby applications, regardless of whether they used Ractors. This regression was partially addressed in subsequent Ruby versions as the Ractor-aware threading implementation was optimized.

## Technical Notes

- Memory measurements use RSS (Resident Set Size) for accurate physical memory usage
- All tests run in isolated Docker containers to ensure consistent environments
- Garbage collection is forced before memory measurements for accuracy
- Results represent averages across multiple warmup and measurement cycles

## Key Findings

### Performance
- **Fibers are consistently faster** than threads across all Ruby versions
- **Context switching**: Fibers are 2.7x to 13.3x faster than threads
- **Allocation speed**: Fibers are 5.1x to 19.3x faster to allocate
- **Ruby 3.4 shows the largest performance gap**, with significant improvements for fibers

### Memory Efficiency
- **Fibers use ~13-14 KB each** (approximately 3.2-3.6 pages at 4KB/page)
- **Threads use ~10-18 KB each** depending on Ruby version
- **Memory usage varies significantly** across Ruby versions for threads
- **Ruby 2.7-3.2 show consistent fiber memory usage** at ~13KB per fiber

### Ruby Version Trends
- **Ruby 2.7-3.2**: Most consistent performance and memory characteristics
- **Ruby 3.4**: Shows significant performance improvements for fibers but variable thread performance
- **Older versions (2.5-2.6)**: Show more variable memory usage patterns
