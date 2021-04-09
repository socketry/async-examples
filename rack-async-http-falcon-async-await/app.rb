require "async/await"

class App
  class << self
    include Async::Await

    sync def call(env)
      puts "Request start"

      results = sort([5, 2, 3, 4, 9, 2, 5, 7, 8]).result

      puts "Request finish"

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

      puts "Waiting at the barrier!"
      barrier!

      puts "Returning the result"
      return result
    end
  end
end
