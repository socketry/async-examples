# Async examples in Ruby

This is a scratchpad for experimenting with Ruby tools with the aim of serving lots of concurrent requests that hit an external http endpoint that may run slowly, returning JSON, ideally using GraphQL, with batching inside or outside of the GraphQL context.

The simplest working example is the `rack-async-http-falcon-graphql-batch` app. This example also includes a working config example for Heroku.

The `rack-async-http-falcon-graphql-lazy-resolve` example demos some additional logging with measurements. Note the time the http requests take on your first request vs the second to see the shared internet instance via thread/local keeping the connection open. 

I'd like to understand why adding graphql-ruby's new dataloader doesn't work well. Also I'm not clear on the tradeoffs involved in using threads versus fibers. I don't have a working example with threads (and Puma?) yet, but I assume it's possible to get working well.

If you'd like to play around with any of these examples, add your own, or fix any that aren't working well, I would love your help!

(All examples are released under the MIT license.)
