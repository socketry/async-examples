require_relative "extension"

ENV["RACK_ENV"] = "none"

unicorn_workers = Integer(ENV.fetch("UNICORN_WORKERS", 1))
worker_processes(unicorn_workers)
preload_app(true)
check_client_connection(true)
timeout(30)
listen(8080, backlog: unicorn_workers * 10)
