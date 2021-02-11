Example app using:
  * rails
  * falcon
  * async-http
  * graphql-batch

Notes:
  * The same idea as rack-async-http-falcon-graphql-batch but using Rails

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
    Document Length:        111 bytes

    Concurrency Level:      100
    Time taken for tests:   4.996 seconds
    Complete requests:      100
    Failed requests:        0
    Total transferred:      59000 bytes
    HTML transferred:       11100 bytes
    Requests per second:    20.02 [#/sec] (mean)
    Time per request:       4996.245 [ms] (mean)
    Time per request:       49.962 [ms] (mean, across all concurrent requests)
    Transfer rate:          11.53 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:       29  227  64.6    264     266
    Processing:  2235 2346  45.7   2348    2508
    Waiting:     2230 2346  45.8   2348    2508
    Total:       2264 2573  63.5   2580    2736

    Percentage of the requests served within a certain time (ms)
      50%   2580
      66%   2605
      75%   2615
      80%   2619
      90%   2628
      95%   2686
      98%   2735
      99%   2736
     100%   2736 (longest request)
