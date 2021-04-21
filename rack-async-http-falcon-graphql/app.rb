require_relative "schema"

class App
  def self.call(env)
    Console.logger.info "Request start"

    result = Schema.execute("query { one two three }")

    Console.logger.info "Request finish"

    [200, {}, [result.to_json]]
  end
end
