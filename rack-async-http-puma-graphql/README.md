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

    puma -t 1
    ab -n 100 -c 100 http://0.0.0.0:9292/

Benchmark results:

  * It's slow...
