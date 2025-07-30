# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require_relative "schema"

run do |env|
    request = Rack::Request.new(env)
    pizza = Pizza.create!(name: "Margherita", status: "cold")

    pizza.cook!

    [200, {"content-type" => "application/json"}, [pizza.to_json]]
end