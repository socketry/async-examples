Example app using:
  * rack
  * falcon
  * async-http
  * graphql

Notes:
  * The same idea as rack-async-http-falcon-graphql but using a graphql-ruby's new dataloader
  * This breaks the async setup in falcon, so only one request runs at a time (?)

Running and benchmarking:

    falcon serve --count 1
    ab -n 100 -c 100 https://localhost:9292/

Benchmark results:

  * It's slow...
