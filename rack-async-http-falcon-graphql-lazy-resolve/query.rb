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

  def delay_1_data
    @_delay_1_data ||= begin
      puts "getting delay_1_data"
      JSON.parse(internet.get("https://httpbin.org/delay/1").read)
    end
  end

  def delay_2_data
    @_delay_2_data ||= begin
      puts "getting delay_2_data"
      JSON.parse(internet.get("https://httpbin.org/delay/2").read)
    end
  end
end
