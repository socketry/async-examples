Example app using:
  * rack
  * falcon
  * async-http
  * graphql

Notes:
  * The same idea as rack-async-http-falcon-graphql, but...
  * Using lazy_resolve instead of a batch loader
  * Re: https://github.com/trevorturk/async-examples/issues/2

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
    Time taken for tests:   5.140 seconds
    Complete requests:      100
    Failed requests:        0
    Total transferred:      18300 bytes
    HTML transferred:       12000 bytes
    Requests per second:    19.45 [#/sec] (mean)
    Time per request:       5140.459 [ms] (mean)
    Time per request:       51.405 [ms] (mean, across all concurrent requests)
    Transfer rate:          3.48 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:       45  219  64.6    270     273
    Processing:  2213 2287  67.8   2258    2570
    Waiting:     2213 2285  68.2   2258    2567
    Total:       2324 2506  71.4   2521    2821

    Percentage of the requests served within a certain time (ms)
      50%   2521
      66%   2527
      75%   2528
      80%   2530
      90%   2605
      95%   2681
      98%   2687
      99%   2821
     100%   2821 (longest request)
