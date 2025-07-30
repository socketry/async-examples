# Rails ActiveRecord

ActiveRecord is compatible with Falcon, however you must specify fiber isolation:

```ruby
ActiveSupport::IsolatedExecutionState.isolation_level = :fiber

# In addition, this helps to avoid connection leaks:
ActiveRecord.permanent_connection_checkout = :disallowed
```

Connections are only checked out when needed, and returned to the pool after use. This allows for a large number of connections to be used without exhausting the database connection pool.

## Results

Tests were run with 4 processes per server.

### Puma (4 workers, 3 threads, the recommended default)

#### `wrk -t1 -c1`

```
> ./wrk -t1 -c1 http://localhost:9293
Running 10s test @ http://localhost:9293
  1 threads and 1 connections
  1671 requests in 10.11s, 326.37KB read
Requests/sec:    165.35
Transfer/sec:     32.30KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:       5.99ms    682.66us      4.84ms     16.16ms   75.75%
     Req/sec:     165.91       16.83       10.00      180.00     98.02%
```

#### `wrk -t4 -c4`

```
> ./wrk -t4 -c4 http://localhost:9293
Running 10s test @ http://localhost:9293
  4 threads and 4 connections
  4608 requests in 10.10s, 0.88MB read
Requests/sec:    456.07
Transfer/sec:     89.08KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:       8.70ms      1.23ms      6.32ms     32.67ms   90.18%
     Req/sec:     115.32        8.12       10.00      130.00     98.25%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:       1.15k       1.63        1.15k       1.15k    50.00%
```

#### `wrk -t4 -c40`

```
> ./wrk -t4 -c40 http://localhost:9293
Running 10s test @ http://localhost:9293
  4 threads and 40 connections
  12444 requests in 10.11s, 2.40MB read
Requests/sec:   1231.06
Transfer/sec:    242.70KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:      67.46ms     79.26ms      7.23ms    318.75ms   79.18%
     Req/sec:     312.84      195.83       10.00      808.00     60.20%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:     311.10        2.61      303.00      315.00     80.00%
```

#### Puma (4 workers, 10 threads)

#### `wrk -t4 -c40`

```
> ./wrk -t4 -c40 http://localhost:9293
Running 10s test @ http://localhost:9293
  4 threads and 40 connections
  22476 requests in 10.11s, 4.29MB read
Requests/sec:   2223.75
Transfer/sec:    434.33KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:      17.87ms      3.33ms     10.08ms     94.67ms   83.27%
     Req/sec:     558.58       71.64       30.00      660.00     94.80%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:     561.90        2.94      558.00      570.00     75.00%
```

#### `wrk -t4 -c80`

```
> ./wrk -t4 -c80 http://localhost:9293
Running 10s test @ http://localhost:9293
  4 threads and 80 connections
  22687 requests in 10.12s, 4.37MB read
Requests/sec:   2241.80
Transfer/sec:    441.88KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:      57.32ms     62.49ms      9.89ms    277.46ms   79.29%
     Req/sec:     565.13      254.63       40.00        1.17k    58.31%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:     283.59        3.67      278.00      293.00     66.25%
```

#### `wrk -t4 -c160`

```
> ./wrk -t4 -c160 http://localhost:9293
Running 10s test @ http://localhost:9293
  4 threads and 160 connections
  22451 requests in 10.14s, 4.32MB read
Requests/sec:   2214.90
Transfer/sec:    436.55KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:     159.35ms    188.75ms      9.43ms    711.67ms   78.77%
     Req/sec:     558.12      365.08       30.00        1.64k    67.33%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:     140.32        4.74      131.00      150.00     64.38%
```

### Puma (4 workers, 40 threads)

```
> ./wrk -t4 -c160 http://localhost:9293
Running 10s test @ http://localhost:9293
  4 threads and 160 connections
  27922 requests in 10.12s, 5.33MB read
Requests/sec:   2759.10
Transfer/sec:    538.89KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:      57.92ms     13.32ms     25.11ms    310.53ms   98.17%
     Req/sec:     704.63       79.15       90.00      840.00     88.66%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:     174.51        0.98      172.00      177.00     76.25%
```

### Falcon (4 processes)

#### `wrk -t1 -c1`

```
> ./wrk -t1 -c1 http://localhost:9292
Running 10s test @ http://localhost:9292
  1 threads and 1 connections
  1664 requests in 10.01s, 362.38KB read
Requests/sec:    166.31
Transfer/sec:     36.22KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:       6.09ms      1.89ms      4.81ms     47.97ms   98.68%
     Req/sec:     166.83       11.37       90.00      181.00     82.00%
```

#### `wrk -t4 -c4`

```
> ./wrk -t4 -c4 http://localhost:9292
Running 10s test @ http://localhost:9292
  4 threads and 4 connections
  4664 requests in 10.11s, 0.99MB read
Requests/sec:    461.41
Transfer/sec:    100.48KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:       8.61ms      1.32ms      5.84ms     36.82ms   93.74%
     Req/sec:     116.16       11.19       10.00      131.00     94.54%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:       1.17k       2.58        1.16k       1.17k    50.00%
```

#### `wrk -t4 -c40`

```
> ./wrk -t4 -c40 http://localhost:9292
Running 10s test @ http://localhost:9292
  4 threads and 40 connections
  32669 requests in 10.11s, 6.95MB read
Requests/sec:   3232.52
Transfer/sec:    703.96KB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:      12.31ms      2.83ms      7.21ms     37.33ms   86.76%
     Req/sec:     814.05      117.78       40.00        0.96k    89.83%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:     816.72       46.61      747.00        0.88k    50.00%
```

#### `wrk -t4 -c80`

```
> ./wrk -t4 -c80 http://localhost:9292
Running 10s test @ http://localhost:9292
  4 threads and 80 connections
  48295 requests in 10.10s, 10.27MB read
Requests/sec:   4779.44
Transfer/sec:      1.02MB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:      16.58ms      2.31ms      8.81ms     57.72ms   73.90%
     Req/sec:       1.21k     109.44      188.00        1.38k    87.81%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:     603.69       16.84      583.00      635.00     60.00%
```

#### `wrk -t4 -c160`

```
> ./wrk -t4 -c160 http://localhost:9292
Running 10s test @ http://localhost:9292
  4 threads and 160 connections
  54013 requests in 10.11s, 11.49MB read
Requests/sec:   5341.84
Transfer/sec:      1.14MB

Thread Stats         Avg       Stdev         Min         Max    +/- Stdev 
     Latency:      30.35ms     12.10ms     14.58ms    223.82ms   95.31%
     Req/sec:       1.36k     184.72       10.00        1.61k    94.25%

Request Stats        Avg       Stdev         Min         Max    +/- Stdev 
    Req/conn:     337.58       42.51      273.00      385.00     56.25%
```
