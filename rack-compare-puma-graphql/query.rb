require_relative "async_loader"
require_relative "fasync_loader"
require_relative "concurrent_loader"

class Query < GraphQL::Schema::Object
  field :asyncurls, [String], null: false do
    description "a collection of urls fetched with async"
    argument :count, Int, required: true
  end
  field :fasyncurls, [String], null: false do
    description "a collection of urls fetched with async/http/faraday"
    argument :count, Int, required: true
  end
  field :concurrenturls, [String], null: false do
    description "a collection of urls fetched with concurrent-ruby and faraday"
    argument :count, Int, required: true
  end

  def asyncurls(count:)
    (0...count).to_a.map do |el|
      AsyncLoader.load("https://httpbin.org/delay/1?type=async&item=#{el}").then do |data|
        data["url"]
      end
    end
  end

  def fasyncurls(count:)
    (0...count).to_a.map do |el|
      FasyncLoader.load("https://httpbin.org/delay/1?type=fasync&item=#{el}").then do |data|
        data["url"]
      end
    end
  end

  def concurrenturls(count:)
    (0...count).to_a.map do |el|
      ConcurrentLoader.load("https://httpbin.org/delay/1?type=concurrent&item=#{el}").then do |data|
        data["url"]
      end
    end
  end
end
