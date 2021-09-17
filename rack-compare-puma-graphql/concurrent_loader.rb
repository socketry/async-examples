require "concurrent-ruby"
require "faraday"

class ConcurrentLoader < GraphQL::Batch::Loader
  def perform(urls)
    results = {}
    urls.each do |url|
      results[url] = Concurrent::Future.execute do
        Console.logger.info "ConcurrentHttp#get: #{url}"
        response = Faraday.get url
        JSON.parse(response.body)
      end
    end
    Console.logger.info "ConcurrentHttp#wait"
    results.each_pair { |url, concurrent_body| fulfill(url, concurrent_body.value!) }
  end
end
