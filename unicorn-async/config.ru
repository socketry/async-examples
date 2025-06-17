class MyApp
	def call(env)
		# Read the request body if it exists
		request_body = env['rack.input']&.read
		
		# If there's a request body, echo it back, otherwise return "Hello, World!"
		response_body = request_body.empty? ? "Hello, World!" : request_body
		
		[200, {"content-type" => "text/plain"}, [response_body]]
	end
end

# Use the MyApp class to handle requests
run MyApp.new
