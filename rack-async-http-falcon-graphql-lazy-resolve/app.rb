require_relative "schema"
require "securerandom"

class App
  def self.call(env)
    logger = Console.logger.with(name: SecureRandom.uuid)

    Async(logger: logger) do
      result = Console.logger.measure(self, "Schema.execute") do
        Schema.execute("query { one two three }")
      end

      [200, {}, [result.to_json]]
    end.wait
  end
end
