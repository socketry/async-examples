require "async"
require "async/barrier"
require "async/http/internet"
require "kernel/sync"

require 'thread/local'

class Async::HTTP::Internet
  extend Thread::Local
end

class AsyncLoader < GraphQL::Batch::Loader
  def perform(urls)
    Sync do
      barrier = Async::Barrier.new
      internet = Async::HTTP::Internet.instance

      urls.each do |url|
        barrier.async do
          Console.logger.info "AsyncHttp#get: #{url}"
          data = JSON.parse(internet.get(url).read)
          fulfill(url, data)
          Console.logger.info "AsyncHttp#fulfill: #{url}"
        end
      end

      Console.logger.info "AsyncHttp#wait"
      barrier.wait
    end
  end
end
