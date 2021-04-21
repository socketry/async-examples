require "async"
require "async/http/internet"

# Re: https://github.com/socketry/async-http/issues/68
class Internet < Async::HTTP::Internet
	def client_for(endpoint)
		Protocol::HTTP::AcceptEncoding.new(super).tap do |middleware|
			def middleware.scheme
				"https"
			end
		end
	end
end

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
