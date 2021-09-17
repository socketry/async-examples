require "async"
require "faraday"
require "async/http/faraday"
require "kernel/sync"

if ENV["RESOLVER"] == "fasync"
  Faraday.default_adapter = :async_http
end

class FasyncLoader < GraphQL::Batch::Loader
  def perform(urls)
    Sync do
      conn = Faraday.new
      barrier = Async::Barrier.new

      urls.each do |url|
        barrier.async do
          Console.logger.info "async/http/faraday#get: #{url}"
          response = conn.get url
          body = JSON.parse(response.body)
          fulfill(url, body)
          Console.logger.info "async/http/faraday#fulfill: #{url}"
        end
      end
      Console.logger.info "async/http/faraday#wait"
      barrier.wait
    end
  end
end
