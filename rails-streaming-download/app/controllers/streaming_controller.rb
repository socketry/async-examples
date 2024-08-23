class StreamingController < ApplicationController
  def index
  end
  
  def download
    headers = {
      'content-type' => 'application/json',
      'cache-control' => 'no-cache',
      'last-modified' => Time.now.httpdate
    }
    
    body = lambda do |stream|
      chunks = Async::Queue.new
    
      request_task = Async do
        $stderr.puts "Downloading..."
        response = Faraday.get("https://httpbin.org/stream/100") do |request|
          request.options.on_data = proc do |chunk|
            $stderr.puts "Received chunk: #{chunk.bytesize}"
            chunks.enqueue(chunk)
          end
        end
        $stderr.puts "Downloaded: #{response}"
        chunks.enqueue(nil)
      ensure
        $stderr.puts "Request Exiting: #{$!}"
      end
      
      while chunk = chunks.dequeue
        stream.write(chunk)
      end
    ensure
      $stderr.puts "Response Exiting: #{$!}"
      request_task&.stop
      stream.close
    end
    
    self.response = Rack::Response[200, headers, body]
  end
end
