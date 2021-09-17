require_relative "schema"

class App
  TIMES = (ENV["TIMES"] || 2).to_i
  RESOLVER = (ENV["RESOLVER"] || 'async')

  def self.call(env)
    Console.logger.info "Request start"

    result = Schema.execute("query { #{RESOLVER}urls(count: #{TIMES}) }")

    Console.logger.info "Request finish"

    [200, {}, [result.to_json]]
  end
end
