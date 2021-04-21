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
    Time taken for tests:   4.661 seconds
    Complete requests:      100
    Failed requests:        0
    Total transferred:      18300 bytes
    HTML transferred:       12000 bytes
    Requests per second:    21.45 [#/sec] (mean)
    Time per request:       4661.288 [ms] (mean)
    Time per request:       46.613 [ms] (mean, across all concurrent requests)
    Transfer rate:          3.83 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:       10  232  67.8    263     266
    Processing:  2033 2117  72.4   2096    2301
    Waiting:     2033 2116  71.6   2095    2300
    Total:       2101 2349  75.3   2337    2565

    Percentage of the requests served within a certain time (ms)
      50%   2337
      66%   2360
      75%   2365
      80%   2369
      90%   2494
      95%   2560
      98%   2564
      99%   2565
     100%   2565 (longest request)
