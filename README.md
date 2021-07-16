# Async examples in Ruby

This is a collection of example apps, mostly using Async::HTTP and Falcon, demonstrating how to serve concurrent requests that hit an external http endpoint that may run slowly, returning JSON, ideally using GraphQL, with batching inside or outside of the GraphQL context.

The simplest working example is the `rack-async-http-falcon-graphql-batch` app. This example also includes a working config example for Heroku.

The `rack-async-http-falcon-graphql-lazy-resolve` example demos some additional logging with measurements. Note the time the http requests take on your first request vs the second to see the shared internet instance via thread/local keeping the connection open.

The `rack-async-http-falcon-graphql-dataloader` and `rack-async-http-puma-graphql` examples are not working yet. Contributions are most welcome if you'd like to help fix those examples, improve the others, or add new ones.

## License

Released under the MIT license.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
