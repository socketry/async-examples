require "async/http/internet"

class Query < GraphQL::Schema::Object
  field :one, String, null: false
  field :two, String, null: false
  field :three, String, null: false

  def one
    delay_1_data do |data|
      data["url"]
    end
  end

  def two
    delay_2_data do |data|
      data["url"]
    end
  end

  def three
    delay_2_data do |data|
      data["url"]
    end
  end

  def internet
    @_internet ||= Async::HTTP::Internet.new
  end

  def delay_1_data(&block)
    @_delay_1_data ||= Async do
      puts "getting delay_1_data"
      yield JSON.parse(internet.get("https://httpbin.org/delay/1").read)
    end
  end

  def delay_2_data(&block)
    @_delay_2_data ||= Async do
      puts "getting delay_2_data"
      yield JSON.parse(internet.get("https://httpbin.org/delay/2").read)
    end
  end
end
