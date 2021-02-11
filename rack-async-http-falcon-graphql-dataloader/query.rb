require_relative "async_loader"

class Query < GraphQL::Schema::Object
  field :one, String, null: false
  field :two, String, null: false
  field :three, String, null: false

  def one
    data = dataloader.with(AsyncLoader).load("https://httpbin.org/delay/1")
    data["url"]
  end

  def two
    data = dataloader.with(AsyncLoader).load("https://httpbin.org/delay/2")
    data["url"]
  end

  def three
    data = dataloader.with(AsyncLoader).load("https://httpbin.org/delay/2")
    data["url"]
  end
end
