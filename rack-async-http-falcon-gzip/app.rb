require "async"
require "async/http/internet"

class App
  def self.call(env)
    puts "Request start"

    internet = Async::HTTP::Internet.new

    url = "https://httpbin.org/delay/1"
    headers = ["Accept-Encoding", "gzip"]

    response = internet.get(url, headers).read
    data = JSON.parse(response)

    puts "Request finish"

    [200, {}, [data.to_json]]
  end
end
