class ApplicationController < ActionController::Base
  def index
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

    render inline: result.to_json
  end
end
