require "async"
require "async/barrier"
require "async/http/internet"
require "kernel/sync"

class AsyncLoader < GraphQL::Batch::Loader
  def perform(urls)
    Sync do
      internet = Async::HTTP::Internet.new
      barrier = Async::Barrier.new

      urls.each do |url|
        barrier.async do
          puts "AsyncHttp#get: #{url}"
          data = JSON.parse(internet.get(url).read)
          fulfill(url, data)
          puts "AsyncHttp#fulfill: #{url}"
        end
      end

      puts "AsyncHttp#wait"
      barrier.wait
    ensure
      puts "AsyncHttp#close"
      internet&.close
    end
  end
end
