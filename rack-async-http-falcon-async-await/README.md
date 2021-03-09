Example app using:
  * rack
  * falcon
  * async-http
  * async-await

 Notes:
   * Based on rack-async-http-falcon-graphql-batch
   * Uses async-await instead of graphql-batch loaders

Running and benchmarking:

    falcon serve --count 1
    ab -n 100 -c 100 https://localhost:9292/

Benchmark results:
