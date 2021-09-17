Example app using:
  * rack
  * puma
  * async-http
  * concurrent-ruby
    * faraday
  * async
    * async-http-faraday
  * graphql
  * graphql-batch

Notes:
  * The same idea as rack-async-http-falcon-graphql but using Puma
  * use ENV vars to control
    * number of "upstream API requests" with `TIMES` (0...100)
      * this means every web request hitting the puma server will make `TIMES` many API calls with the type of resolver you are testing. The calls are for unique versions of `https://httpbin.org/delay/1` which has a ~1s response time.
    * graphql resolved method with `RESOLVER` (async|fasync|concurrent)

Running and benchmarking:

    Run server with desired configuration:
    RESOLVER=async TIMES=7 puma -w 5 -t 1:10 --preload
    RESOLVER=fasync TIMES=7 puma -w 5 -t 1:10 --preload
    RESOLVER=concurrent TIMES=7 puma -w 5 -t 1:10 --preload

    Benchmark:
    ab -n 100 -c 100 http://0.0.0.0:9292/

Benchmark results:

These results are for simple comparison run on a single machine without a controlled environment, expect variations between runs... This is mostly for basic self testing and exploration, opposed to rigorous benchmarking statistics. 

**NOTE: I reduced to TIMES=30 becuase concurrent starts to suffer frequent errors going above 30 upstream calls, while async could scale to a higher number of calls without errors...**

Async: `RESOLVER=async TIMES=30 puma -w 5 -t 1:10 --preload`

```
ab -n 100 -c 100 http://0.0.0.0:9292/

Concurrency Level:      100
Time taken for tests:   6.194 seconds
Complete requests:      100
Failed requests:        1
   (Connect: 0, Receive: 0, Length: 1, Exceptions: 0)
Non-2xx responses:      1
Total transferred:      151615 bytes
HTML transferred:       147497 bytes
Requests per second:    16.14 [#/sec] (mean)
Time per request:       6194.089 [ms] (mean)
Time per request:       61.941 [ms] (mean, across all concurrent requests)
Transfer rate:          23.90 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    4   1.4      3       6
Processing:  1562 2494 941.8   2520    4632
Waiting:     1546 2488 944.5   2520    4632
Total:       1562 2498 941.4   2524    4635

Percentage of the requests served within a certain time (ms)
  50%   2524
  66%   3095
  75%   3109
  80%   3124
  90%   3376
  95%   4510
  98%   4562
  99%   4635
 100%   4635 (longest request)
```

Faraday Async: `RESOLVER=fasync TIMES=30 puma -w 5 -t 1:10 --preload`

```
ab -n 100 -c 100 http://0.0.0.0:9292/

Concurrency Level:      100
Time taken for tests:   6.239 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      155600 bytes
HTML transferred:       151500 bytes
Requests per second:    16.03 [#/sec] (mean)
Time per request:       6238.804 [ms] (mean)
Time per request:       62.388 [ms] (mean, across all concurrent requests)
Transfer rate:          24.36 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    3   1.4      3       6
Processing:  1436 2482 811.9   2622    4677
Waiting:     1428 2479 814.0   2622    4677
Total:       1441 2486 811.8   2627    4682

Percentage of the requests served within a certain time (ms)
  50%   2627
  66%   3056
  75%   3162
  80%   3196
  90%   3216
  95%   3934
  98%   4571
  99%   4682
 100%   4682 (longest request)
```

Concurrent-Ruby (threads): `RESOLVER=concurrent TIMES=30 puma -w 5 -t 1:10 --preload`

```
ab -n 100 -c 100 http://0.0.0.0:9292/

Concurrency Level:      100
Time taken for tests:   9.495 seconds
Complete requests:      100
Failed requests:        1
   (Connect: 0, Receive: 0, Length: 1, Exceptions: 0)
Non-2xx responses:      1
Total transferred:      170545 bytes
HTML transferred:       166426 bytes
Requests per second:    10.53 [#/sec] (mean)
Time per request:       9495.348 [ms] (mean)
Time per request:       94.953 [ms] (mean, across all concurrent requests)
Transfer rate:          17.54 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    6   2.8      6      12
Processing:  1970 4058 1136.8   3719    6981
Waiting:     1970 4049 1141.4   3668    6981
Total:       1972 4064 1138.2   3723    6991

Percentage of the requests served within a certain time (ms)
  50%   3723
  66%   4955
  75%   5175
  80%   5197
  90%   5335
  95%   5859
  98%   6744
  99%   6991
 100%   6991 (longest request)
```