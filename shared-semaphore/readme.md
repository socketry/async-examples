# Shared Semaphore

This example demonstrates how to use a shared semaphore across multiple processes using `Async::Container` to coordinate access to a resource.

## Usage

Simply run the `work.rb` script to start the controller and worker processes:

```bash
bundle install
bundle exec ./work.rb
```

### Output

```
> bundle exec ./work.rb
  0.0s     info: Async::Container::Notify::Console [oid=0x1d8] [ec=0x1e0] [pid=396073] [2025-07-28 12:48:43 +1200]
               | {status: "Initializing controller..."}
  0.0s     info: Controller [oid=0x1f0] [ec=0x1e0] [pid=396073] [2025-07-28 12:48:43 +1200]
               | Controller starting...
  0.0s     info: Waiting for availability... [ec=0x1f8] [pid=396075] [2025-07-28 12:48:43 +1200]
  0.0s     info: Available: "." [ec=0x1f8] [pid=396075] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x208] [pid=396078] [2025-07-28 12:48:43 +1200]
  0.0s     info: Available: "." [ec=0x208] [pid=396078] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x218] [pid=396081] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x228] [pid=396084] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x238] [pid=396087] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x248] [pid=396090] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x258] [pid=396093] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x268] [pid=396096] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x278] [pid=396099] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x288] [pid=396102] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x298] [pid=396105] [2025-07-28 12:48:43 +1200]
  0.0s     info: Waiting for availability... [ec=0x2a8] [pid=396108] [2025-07-28 12:48:43 +1200]
  1.0s     info: Notifying that work is done... [ec=0x1f8] [pid=396075] [2025-07-28 12:48:44 +1200]
  1.0s     info: Waiting for availability... [ec=0x1f8] [pid=396075] [2025-07-28 12:48:44 +1200]
  1.0s     info: Available: "." [ec=0x298] [pid=396105] [2025-07-28 12:48:44 +1200]
  1.0s     info: Notifying that work is done... [ec=0x208] [pid=396078] [2025-07-28 12:48:44 +1200]
  1.0s     info: Waiting for availability... [ec=0x208] [pid=396078] [2025-07-28 12:48:44 +1200]
  1.0s     info: Available: "." [ec=0x288] [pid=396102] [2025-07-28 12:48:44 +1200]
  2.0s     info: Notifying that work is done... [ec=0x288] [pid=396102] [2025-07-28 12:48:45 +1200]
  2.0s     info: Notifying that work is done... [ec=0x298] [pid=396105] [2025-07-28 12:48:45 +1200]
  2.0s     info: Waiting for availability... [ec=0x288] [pid=396102] [2025-07-28 12:48:45 +1200]
  2.0s     info: Available: "." [ec=0x288] [pid=396102] [2025-07-28 12:48:45 +1200]
  2.0s     info: Waiting for availability... [ec=0x298] [pid=396105] [2025-07-28 12:48:45 +1200]
  2.0s     info: Available: "." [ec=0x248] [pid=396090] [2025-07-28 12:48:45 +1200]
  3.0s     info: Notifying that work is done... [ec=0x288] [pid=396102] [2025-07-28 12:48:46 +1200]
  3.0s     info: Notifying that work is done... [ec=0x248] [pid=396090] [2025-07-28 12:48:46 +1200]
  3.0s     info: Waiting for availability... [ec=0x288] [pid=396102] [2025-07-28 12:48:46 +1200]
  3.0s     info: Waiting for availability... [ec=0x248] [pid=396090] [2025-07-28 12:48:46 +1200]
  3.0s     info: Available: "." [ec=0x288] [pid=396102] [2025-07-28 12:48:46 +1200]
  3.0s     info: Available: "." [ec=0x238] [pid=396087] [2025-07-28 12:48:46 +1200]
  4.0s     info: Notifying that work is done... [ec=0x288] [pid=396102] [2025-07-28 12:48:47 +1200]
  4.0s     info: Waiting for availability... [ec=0x288] [pid=396102] [2025-07-28 12:48:47 +1200]
  4.0s     info: Available: "." [ec=0x268] [pid=396096] [2025-07-28 12:48:47 +1200]
  4.0s     info: Notifying that work is done... [ec=0x238] [pid=396087] [2025-07-28 12:48:47 +1200]
  4.0s     info: Waiting for availability... [ec=0x238] [pid=396087] [2025-07-28 12:48:47 +1200]
  4.0s     info: Available: "." [ec=0x278] [pid=396099] [2025-07-28 12:48:47 +1200]
```

We've deliberately set the number of worker processes to 12, which allows us to see how the semaphore controls access to the shared resource. Each worker will wait for availability before proceeding, demonstrating the coordination provided by the semaphore. There is no guarantee of fair scheduling, so the order in which workers acquire the semaphore may vary.
