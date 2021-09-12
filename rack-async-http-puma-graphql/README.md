Example app using:
  * rack
  * puma
  * async-http
  * graphql
  * graphql-batch

Notes:
  * The same idea as rack-async-http-falcon-graphql but using Puma
  * It's slow, only runs one request at a time
  * Probably need to spin up a thread per async request?

Running and benchmarking:

    puma -w 5 -t 1:10 --preload
    ab -n 100 -c 100 http://0.0.0.0:9292/

Benchmark results:

Results from MacBook Pro (15-inch, 2018)
  * 2.6 GHz 6-Core Intel Core i7
  * 32 GB 2400 MHz DDR4

```
ab -n 100 -c 100 http://0.0.0.0:9292/

This is ApacheBench, Version 2.3 <$Revision: 1879490 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 0.0.0.0 (be patient).....done


Server Software:
Server Hostname:        0.0.0.0
Server Port:            9292

Document Path:          /
Document Length:        120 bytes

Concurrency Level:      100
Time taken for tests:   9.309 seconds
Complete requests:      100
Failed requests:        0
Total transferred:      16000 bytes
HTML transferred:       12000 bytes
Requests per second:    10.74 [#/sec] (mean)
Time per request:       9308.814 [ms] (mean)
Time per request:       93.088 [ms] (mean, across all concurrent requests)
Transfer rate:          1.68 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    4   1.7      4       7
Processing:  2280 3587 1411.2   2588    7028
Waiting:     2273 3585 1412.3   2588    7027
Total:       2280 3591 1411.7   2589    7030

Percentage of the requests served within a certain time (ms)
  50%   2589
  66%   4614
  75%   4615
  80%   4615
  90%   4706
  95%   6857
  98%   6858
  99%   7030
 100%   7030 (longest request)
```