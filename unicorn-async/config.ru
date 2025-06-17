
require_relative "unicorn"

run ->(env) {[200, {"content-type" => "text/plain"}, ["Hello, World!"]]}
