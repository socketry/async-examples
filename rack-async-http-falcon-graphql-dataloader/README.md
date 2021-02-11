Example app using:
  * rack
  * falcon
  * async-http
  * graphql

Notes:
  * The same idea as rack-async-http-falcon-graphql but using a graphql-ruby's new dataloader
  * https://graphql-ruby.org/guides#dataloader-guides
  * This breaks the async setup in falcon, so only one request runs at a time (?)
  * I'm probably doing something wrong, but I'm not sure what
  * Perhaps we're supposed to use threads?
  * https://graphql-ruby.org/dataloader/sources.html#example-loading-in-a-background-thread

Running and benchmarking:

    falcon serve --count 1
    ab -n 100 -c 100 https://localhost:9292/

Benchmark results:

  * It's slow...
