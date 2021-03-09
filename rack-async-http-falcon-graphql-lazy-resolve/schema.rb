require_relative "query"

class Schema < GraphQL::Schema
  query Query
  lazy_resolve Async::Task, :wait
end
