#!/usr/bin/env ruby
# frozen_string_literal: true

require "async/container/controller"

class Controller < Async::Container::Controller
	def create_container
		Async::Container::Forked.new
		# or Async::Container::Threaded.new
		# or Async::Container::Hybrid.new
	end
	
	def start
		@available, @ready = IO.pipe
		@ready.write("." * 2)
		
		super
	end
	
	def stop
		@available.close
		@ready.close

		super
	end
	
	def setup(container)
		container.run count: 12, restart: true do |instance|
			while true
				begin
					Console.info "Waiting for availability..."
					result = @available.read(1)
					Console.info "Available: #{result.inspect}"
					
					# Simulate some work:
					sleep(1)
					
				ensure
					if result
						Console.info "Notifying that work is done..."
						@ready.write(result)
						result = nil
					end
				end
			end
		end
	end
end

controller = Controller.new

controller.run