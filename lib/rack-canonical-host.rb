module Rack # :nodoc:
  class CanonicalHost
    def initialize(app, host=nil, &block)
      @app = app
      @host = host
      @block = block
    end

    def call(env)
      if  Rack::Request.new(env).url =~ /www\./ and url = url(env)
        [301, { 'Location' => url }, ['Redirecting...']]
      else
        @app.call(env)
      end
    end

    def url(env)
      if (host = host(env)) && env['SERVER_NAME'] != host
        url = Rack::Request.new(env).url
        url.sub(%r{\A(https?://)www(.*?)(:\d+)?(/|$)}, "\\1#{host}\\3/")
      end
    end
    private :url

    def host(env)
      @block ? @block.call(env) || @host : @host
    end
    private :host
  end
end
