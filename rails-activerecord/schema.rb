#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "active_record"

require "console"
require "console/compatible/logger"

ActiveSupport::IsolatedExecutionState.isolation_level = :fiber
ActiveRecord.permanent_connection_checkout = :disallowed

ActiveRecord::Base.establish_connection(
	adapter: "postgresql",
	database: "pizzas",
	pool: 40,
)

ActiveRecord::Base.logger = Console::Compatible::Logger.new(Console)

ActiveRecord::Schema.define do
	create_table :pizzas, if_not_exists: true do |table|
		table.string :name, null: false
		table.string :status, null: false
		table.timestamps
	end
end

class Pizza < ActiveRecord::Base
	validates :name, presence: true
	
	def cook!(duration = 0.001)
		update!(status: 'cooking')
		sleep(duration)
		update!(status: 'hot')
	end
end
