Example app using:
  * rack
  * falcon
  * async-http
  * graphql
  * async-await

Notes:
  * The same idea as rack-async-http-falcon-graphql-lazy-resolve, but...
  * Using Async::Await instead of Async blocks

Running and benchmarking:

    falcon serve --count 1
    ab -n 100 -c 100 https://localhost:9292/

Benchmark results:

    Server Software:        
    Server Hostname:        localhost
    Server Port:            9292
    SSL/TLS Protocol:       TLSv1.2,ECDHE-RSA-AES256-GCM-SHA384,2048,256
    Server Temp Key:        ECDH P-256 256 bits
    TLS Server Name:        localhost

    Document Path:          /
    Document Length:        120 bytes

    Concurrency Level:      100
    Time taken for tests:   4.720 seconds
    Complete requests:      100
    Failed requests:        0
    Total transferred:      18300 bytes
    HTML transferred:       12000 bytes
    Requests per second:    21.19 [#/sec] (mean)
    Time per request:       4719.873 [ms] (mean)
    Time per request:       47.199 [ms] (mean, across all concurrent requests)
    Transfer rate:          3.79 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:       45  243  37.5    243     324
    Processing:  2120 2188  37.1   2172    2297
    Waiting:     2120 2183  38.3   2171    2297
    Total:       2209 2432  48.9   2416    2516

    Percentage of the requests served within a certain time (ms)
      50%   2416
      66%   2454
      75%   2486
      80%   2488
      90%   2491
      95%   2499
      98%   2513
      99%   2516
     100%   2516 (longest request)
