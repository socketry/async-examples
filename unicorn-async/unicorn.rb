ENV["RACK_ENV"] = "none"

unicorn_workers = Integer(ENV.fetch("UNICORN_WORKERS", 2))
worker_processes(unicorn_workers)
preload_app(true)
check_client_connection(true)
timeout(30)
listen(9292, backlog: unicorn_workers * 10)

module AsyncUnicorn
  def worker_loop(worker)
    Sync do
      super
    end
  end
end

begin
  require "async"
  require "unicorn/http_server"
  Unicorn::HttpServer.prepend(AsyncUnicorn)

  warn "Running Unicorn with Async #{IO::Event::Selector.default}"
rescue LoadError
  warn "Async is not available. Please install the async gem."
end
