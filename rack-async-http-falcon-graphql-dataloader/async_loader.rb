require "async"
require "async/barrier"
require "async/http/internet"
require "kernel/sync"
require "thread/local"

class Async::HTTP::Internet
  extend Thread::Local
end

class AsyncLoader < GraphQL::Dataloader::Source
  def fetch(urls)
    Sync do
      internet = Async::HTTP::Internet.instance
      barrier = Async::Barrier.new
      values = []

      urls.each do |url|
        barrier.async do
          Console.logger.info "AsyncHttp#get: #{url}"
          body = JSON.parse(internet.get(url).read)
          values << body
          Console.logger.info "AsyncHttp#fulfill: #{url}"
        end
      end

      Console.logger.info "AsyncHttp#wait"
      barrier.wait
      values
    end
  end
end
