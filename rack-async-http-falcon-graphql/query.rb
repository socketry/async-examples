require_relative "async_loader"

class Query < GraphQL::Schema::Object
  field :one, String, null: false
  field :two, String, null: false
  field :three, String, null: false

  def one
    AsyncLoader.load("https://httpbin.org/delay/1").then do |data|
      data["url"]
    end
  end

  def two
    AsyncLoader.load("https://httpbin.org/delay/2").then do |data|
      data["url"]
    end
  end

  def three
    AsyncLoader.load("https://httpbin.org/delay/2").then do |data|
      data["url"]
    end
  end
end
