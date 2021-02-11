require_relative "async_loader"

class App
  def self.call(env)
    puts "Request start"

    response = {}

    GraphQL::Batch.batch do
      AsyncLoader.load("https://httpbin.org/delay/1").then do |data|
        response.merge!(one: data["url"])
      end

      AsyncLoader.load("https://httpbin.org/delay/2").then do |data|
        response.merge!(two: data["url"])
      end

      AsyncLoader.load("https://httpbin.org/delay/2").then do |data|
        response.merge!(three: data["url"])
      end
    end

    puts "Request finish"

    [200, {}, [response.to_json]]
  end
end
