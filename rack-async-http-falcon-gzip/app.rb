require "async"
require "async/http/internet"

class App
  def self.call(env)
    internet = Async::HTTP::Internet.new
    url = "http://httpbin.org/gzip"

    # headers can be a hash...
    headers = {
      "accept-encoding" => "gzip",
      "user-agent" => "example",
    }

    # ...or an array...
    headers = [
      ["accept-encoding", "gzip"],
      ["user-agent", "example"],
    ]

    begin
      response = internet.get(url, headers)
      body = JSON.parse(response.read)
    ensure
      response.finish
    end

    [200, {}, [body.to_json]]
  end
end
