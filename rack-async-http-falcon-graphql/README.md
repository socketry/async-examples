Example app using:
  * rack
  * falcon
  * async-http
  * graphql
  * graphql-batch

Notes:
  * The same idea as rack-async-http-falcon-graphql-batch but using a graphql-ruby schema

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
    Time taken for tests:   4.976 seconds
    Complete requests:      100
    Failed requests:        0
    Total transferred:      18300 bytes
    HTML transferred:       12000 bytes
    Requests per second:    20.10 [#/sec] (mean)
    Time per request:       4976.002 [ms] (mean)
    Time per request:       49.760 [ms] (mean, across all concurrent requests)
    Transfer rate:          3.59 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:       29  220  64.9    265     269
    Processing:  2162 2277  64.9   2272    2522
    Waiting:     2156 2274  65.3   2269    2522
    Total:       2192 2498  99.8   2510    2789

    Percentage of the requests served within a certain time (ms)
      50%   2510
      66%   2549
      75%   2556
      80%   2557
      90%   2558
      95%   2728
      98%   2732
      99%   2789
     100%   2789 (longest request)
