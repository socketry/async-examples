require "async"
require "async/barrier"
require "async/http/internet"
require "kernel/sync"

class AsyncLoader < GraphQL::Dataloader::Source
  def fetch(urls)
    Sync do
      internet = Async::HTTP::Internet.new
      barrier = Async::Barrier.new
      values = []

      urls.each do |url|
        barrier.async do
          puts "AsyncHttp#get: #{url}"
          data = JSON.parse(internet.get(url).read)
          values << data
          puts "AsyncHttp#fulfill: #{url}"
        end
      end

      puts "AsyncHttp#wait"
      barrier.wait
      values
    ensure
      puts "AsyncHttp#close"
      internet&.close
    end
  end
end
