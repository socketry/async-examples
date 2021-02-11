require_relative "schema"

class App
  def self.call(env)
    puts "Request start"

    result = Schema.execute("query { one two three }")

    puts "Request finish"

    [200, {}, [result.to_json]]
  end
end
