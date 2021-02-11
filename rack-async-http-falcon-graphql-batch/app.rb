require_relative "async_loader"

class App
  def self.call(env)
    puts "Request start"

    data = {}

    GraphQL::Batch.batch do
      AsyncLoader.load("https://httpbin.org/delay/1").then do
        data.merge!(one: "delay/1")
      end

      AsyncLoader.load("https://httpbin.org/delay/2").then do
        data.merge!(two: "delay/2")
      end

      AsyncLoader.load("https://httpbin.org/delay/2").then do
        data.merge!(three: "delay/2 again")
      end
    end

    puts "Request finish"

    [200, {}, [data.to_json]]
  end
end
