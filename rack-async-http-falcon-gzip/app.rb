require "async"
require "async/http/internet"

class App
  def self.call(env)
    internet = Async::HTTP::Internet.new
    url = "https://httpbin.org/delay/1"

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

    response = internet.get(url, headers)
    body = JSON.parse(response.read)

    [200, {}, [body.to_json]]
  end
end
