
module AsyncUnicorn
	def worker_loop(worker)
		Sync do
			super
		end
	end
	
	def process_client(client)
		$stderr.puts "Processing client: #{client.inspect}"
		super
	rescue => error
		$stderr.puts "Error processing client: #{error.message}"
		$stderr.puts error.backtrace.join("\n")
		raise
	ensure
		$stderr.puts "Finished processing client: #{client.inspect}"
	end
end

module AsyncUnicornWorker
	def fake_sig(sig)
		$stderr.puts "Fake signal: #{sig}"
		super
	end
end

begin
	require "async"
	require "unicorn/http_server"
	require "unicorn/worker"
	
	class Unicorn::HttpServer
		# runs inside each forked worker, this sits around and waits
		# for connections and doesn't die until the parent dies (or is
		# given a INT, QUIT, or TERM signal)
		def worker_loop(worker)
			$stderr.puts "\nworker=#{worker.nr} PID:#{$$} spawned"

			readers = init_worker_process(worker)
			waiter = prep_readers(readers)
			reopen = false

			# this only works immediately if the master sent us the signal
			# (which is the normal case)
			trap(:USR1) { reopen = true }

			ready = readers.dup
			@after_worker_ready.call(self, worker)

			begin
				reopen = reopen_worker_logs(worker.nr) if reopen
				worker.tick = time_now.to_i
				while sock = ready.shift
					$stderr.puts "worker=#{worker.nr} PID:#{$$} accepting clients on #{sock.inspect}"
					# Unicorn::Worker#kgio_tryaccept is not like accept(2) at all,
					# but that will return false
					if client = sock.kgio_tryaccept
						$stderr.puts "worker=#{worker.nr} PID:#{$$} accepted client"
						process_client(client)
						worker.tick = time_now.to_i
					end
					break if reopen
				end

				# timeout so we can .tick and keep parent from SIGKILL-ing us
				worker.tick = time_now.to_i
				$stderr.puts "worker=#{worker.nr} PID:#{$$} waiting for client to connect"
				waiter.get_readers(ready, readers, @timeout)
				if ready.empty?
					$stderr.puts "worker=#{worker.nr} PID:#{$$} timeout waiting for clients"
				else
					$stderr.puts "worker=#{worker.nr} PID:#{$$} socket became ready: #{ready.inspect}"
				end
			rescue => e
				redo if reopen && readers[0]
				Unicorn.log_error(@logger, "listen loop error", e) if readers[0]
			end while readers[0]
		end
		
		# once a client is accepted, it is processed in its entirety here
		# in 3 easy steps: read request, call app, write app response
		def process_client(client)
			@request = Unicorn::HttpRequest.new
			env = @request.read(client)

			if early_hints
				env["rack.early_hints"] = lambda do |headers|
					$stderr.puts "Sending early hints for client: #{client.inspect}"
					e103_response_write(client, headers)
				end
			end

			env["rack.after_reply"] = []

			$stderr.puts "Processing request: #{env.inspect}"
			status, headers, body = @app.call(env)
			$stderr.puts "Response status: #{status}, headers: #{headers.inspect}, body: #{body.inspect}"

			begin
				return if @request.hijacked?

				if 100 == status.to_i
					$stderr.puts "Sending 100 Continue response for client: #{client.inspect}"
					e100_response_write(client, env)
					status, headers, body = @app.call(env)
					return if @request.hijacked?
				end
				@request.headers? or headers = nil
				$stderr.puts "Writing response for client: #{client.inspect}, status: #{status}, headers: #{headers.inspect}"
				http_response_write(client, status, headers, body, @request)
			ensure
				body.respond_to?(:close) and body.close
			end

			unless client.closed? # rack.hijack may've close this for us
				client.shutdown # in case of fork() in Rack app
				client.close # flush and uncork socket immediately, no keepalive
			end
		rescue => e
			handle_error(client, e)
		ensure
			$stderr.puts "Finished processing request for client: #{client.inspect} after_reply callbacks: #{env["rack.after_reply"].inspect}"
			# run after_reply callbacks, if any
			env["rack.after_reply"].each(&:call) if env
		end
	end
	
	Unicorn::HttpServer.prepend(AsyncUnicorn)
	Unicorn::Worker.prepend(AsyncUnicornWorker)
	
	warn "Running Unicorn with Async #{IO::Event::Selector.default}"
rescue LoadError
	warn "Async is not available. Please install the async gem."
end
