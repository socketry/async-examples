 # Note that Unicorn's internal socket handling does not work with the iouring event selector.
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
rescue LoadError
  warn "Async is not available. Please install the async gem."
end
