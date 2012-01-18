# encoding: UTF-8

module RedisKnock
  class Middleware
    attr_reader :app, :options

    def initialize(app, options = {})
      @app, @options = app, options
    end

    def call(env)
      request = Rack::Request.new env
      control = RedisKnock::Control.new options
      control.allowed?(request) ? app.call(env) : limit_exceeded
    end

    private

    def limit_exceeded
      message = 'Rate limit exceeded'

      headers = {}
      headers['Content-Type'] = 'text/plain; charset=utf-8'
      headers['Content-Length'] = message.length.to_s

      [ 403, headers, [ message ] ]
    end
  end
end

