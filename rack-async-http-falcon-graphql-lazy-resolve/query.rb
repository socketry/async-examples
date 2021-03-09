require "async/http/internet"

class Query < GraphQL::Schema::Object
  field :one, String, null: false
  field :two, String, null: false
  field :three, String, null: false

  def one
    Async do
      response = Async::HTTP::Internet.new.get("https://httpbin.org/delay/1").read
      JSON.parse(response)["url"]
    end
  end

  def two
    Async do
      response = Async::HTTP::Internet.new.get("https://httpbin.org/delay/2").read
      JSON.parse(response)["url"]
    end
  end

  def three
    Async do
      response = Async::HTTP::Internet.new.get("https://httpbin.org/delay/2").read
      JSON.parse(response)["url"]
    end
  end
end
