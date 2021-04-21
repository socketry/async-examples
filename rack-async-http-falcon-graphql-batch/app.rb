require_relative "async_loader"

class App
  def self.call(env)
    Console.logger.info "Request start"

    result = {}

    GraphQL::Batch.batch do
      AsyncLoader.load("https://httpbin.org/delay/1").then do |data|
        result.merge!(one: data["url"])
      end

      AsyncLoader.load("https://httpbin.org/delay/2").then do |data|
        result.merge!(two: data["url"])
      end

      AsyncLoader.load("https://httpbin.org/delay/2").then do |data|
        result.merge!(three: data["url"])
      end
    end

    Console.logger.info "Request finish"

    [200, {}, [result.to_json]]
  end
end
