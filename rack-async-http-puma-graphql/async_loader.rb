require "async"
require "async/barrier"
require "async/http/internet/instance"
require "kernel/sync"

class AsyncLoader < GraphQL::Batch::Loader
  def perform(urls)
    Sync do
      internet = Async::HTTP::Internet.instance
      barrier = Async::Barrier.new

      urls.each do |url|
        barrier.async do
          Console.logger.info "AsyncHttp#get: #{url}"
          begin
            response = internet.get(url)
            body = JSON.parse(response.read)
            fulfill(url, body)
          ensure
            response.finish
          end
          Console.logger.info "AsyncHttp#fulfill: #{url}"
        end
      end

      Console.logger.info "AsyncHttp#wait"
      barrier.wait
    end
  end
end
