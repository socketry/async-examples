Example app using:
  * rack
  * falcon
  * async-http
  * graphql
  * graphql-batch

Notes:
  * Like `rack-async-http-falcon-graphql-batch` but using a graphql-ruby schema

Running and benchmarking:

    falcon serve --count 1
    ab -n 100 -c 100 https://localhost:9292/

Benchmark results:
