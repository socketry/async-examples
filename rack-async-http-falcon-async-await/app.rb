# Pulling from the example here:
# https://github.com/socketry/async-await/blob/00052e12a80ff02b3821222c52a8aed5f1c99799/examples/sleep_sort.rb

require "async/await"

class App
  class << self
    include Async::Await

    sync def call(env)
      puts "Request start"

      results = sort([5, 2, 3, 4, 9, 2, 5, 7, 8]).result

      puts "Request finish"

      # Logs:
      # Request start
      # Waiting at the barrier!
      # I've sorted 2 for you.
      # I've sorted 2 for you.
      # I've sorted 3 for you.
      # I've sorted 4 for you.
      # I've sorted 5 for you.
      # Returning the result
      # Request finish
      # I've sorted 5 for you.
      # I've sorted 7 for you.
      # I've sorted 8 for you.
      # I've sorted 9 for you.

      # Returns [2,2,3,4,5]
      [200, {}, [results.to_json]]
    end

    async def sort_one(item, into)
      sleep(item.to_f)
      into << item

      puts "I've sorted #{item} for you."
    end

    async def sort(items)
      result = []

      items.each do |item|
        sort_one(item, result)
      end

      # Wait until all previous async method calls have finished executing.
      puts "Waiting at the barrier!"
      barrier!

      puts "Returning the result"
      return result
    end
  end
end

# WIP trying to get something along these lines working...

# require "async/http/internet"
# require "async/await"
#
# class App
#   class << self
#     include Async::Await
#
#     sync def call(env)
#       puts "Request start"
#
#       result = {}
#
#       delay_1_data
#       delay_2_data
#       barrier!
#
#       result.merge!(one: delay_1_data["url"])
#       result.merge!(two: delay_2_data["url"])
#       result.merge!(three: delay_2_data["url"])
#
#       raise result.inspect
#
#       puts "Request finish"
#
#       [200, {}, [result.to_json]]
#     end
#
#     async def fetch_data(url)
#       internet = Async::HTTP::Internet.new
#       return JSON.parse(internet.get(url).read)
#     ensure
#       internet&.close
#     end
#
#     async def delay_1_data
#       @_delay_1_data ||= fetch_data("https://httpbin.org/delay/1")
#     end
#
#     async def delay_2_data
#       @_delay_2_data ||= fetch_data("https://httpbin.org/delay/2")
#     end
#   end
# end
