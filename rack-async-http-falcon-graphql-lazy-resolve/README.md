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
