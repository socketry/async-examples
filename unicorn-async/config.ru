
class MyApp
	def call(env)
		[200, {"content-type" => "text/plain"}, ["Hello, World!"]]
	end
end

# Use the MyApp class to handle requests
run MyApp.new
