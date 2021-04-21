require "async"
require "async/barrier"
require "async/http/internet"
require "thread/local"
require "kernel/sync"

class Async::HTTP::Internet
  extend Thread::Local
end

class AsyncLoader < GraphQL::Batch::Loader
  def perform(urls)
    Sync do
      internet = Async::HTTP::Internet.instance
      barrier = Async::Barrier.new

      urls.each do |url|
        barrier.async do
          Console.logger.info "AsyncHttp#get: #{url}"
          body = JSON.parse(internet.get(url).read)
          fulfill(url, body)
          Console.logger.info "AsyncHttp#fulfill: #{url}"
        end
      end

      Console.logger.info "AsyncHttp#wait"
      barrier.wait
    end
  end
end
