require "async/http/internet"

class Query < GraphQL::Schema::Object
  field :one, String, null: false
  field :two, String, null: false
  field :three, String, null: false

  def one
    Async { delay_1_data["url"] }
  end

  def two
    Async { delay_2_data["url"] }
  end

  def three
    Async { delay_2_data["url"] }
  end

  def internet
    @_internet ||= Async::HTTP::Internet.new
  end

  def delay_1_semaphore
    @_delay_1_semaphore ||= Async::Semaphore.new
  end

  def delay_2_semaphore
    @_delay_2_semaphore ||= Async::Semaphore.new
  end

  def delay_1_data
    delay_1_semaphore.async do |task|
      @_delay_1_data ||= begin
        puts "-> delay_1_data"
        data = JSON.parse(internet.get("https://httpbin.org/delay/1").read)
        puts "<- delay_1_data"
        data
      end
    end.result
  end

  def delay_2_data
    delay_2_semaphore.async do |task|
      @_delay_2_data ||= begin
        puts "-> delay_2_data"
        data = JSON.parse(internet.get("https://httpbin.org/delay/2").read)
        puts "<- delay_2_data"
        data
      end
    end.result
  end
end
