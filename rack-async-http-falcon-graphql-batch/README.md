Example app using:
  * rack
  * falcon
  * async-http
  * graphql-batch

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
    Document Length:        57 bytes

    Concurrency Level:      100
    Time taken for tests:   4.686 seconds
    Complete requests:      100
    Failed requests:        0
    Total transferred:      11900 bytes
    HTML transferred:       5700 bytes
    Requests per second:    21.34 [#/sec] (mean)
    Time per request:       4685.604 [ms] (mean)
    Time per request:       46.856 [ms] (mean, across all concurrent requests)
    Transfer rate:          2.48 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:       10  244  61.1    265     269
    Processing:  2143 2238  25.9   2239    2316
    Waiting:     2136 2236  26.5   2237    2314
    Total:       2153 2481  64.8   2503    2536

    Percentage of the requests served within a certain time (ms)
      50%   2503
      66%   2517
      75%   2521
      80%   2524
      90%   2532
      95%   2533
      98%   2536
      99%   2536
     100%   2536 (longest request)

 Notes:
   * Runs on Heroku via Procfile
   * Seems to support ASYNC_CONTAINER_PROCESSOR_COUNT=20 (?)
