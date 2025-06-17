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
