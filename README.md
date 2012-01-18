Ruby HTTP Throttle Control Engine using Redis 
=============================================

This gem implements a simple HTTP throttle control using [Redis][] as database engine to store rate-limiting IP's.

Why not rack-throttle?
------------------------

The gem [rack-throttle][] works with the same principle and does very well the job, but stores IP's and never clears the database.
The main goal of Redis Knock is the use of Redis **[expire][]** command, that removes the key after X seconds.

Usage
-----

### Using in your Rails Controller with before_filter

    # app/controllers/simple_controller.rb

    require 'redis_knock'

    class SimpleController < ApplicationController
      before_filter :check_throttle

      private
      def check_throttle
        control = RedisKnock::Control.new limit: 1000, interval: 1.hour, redis: { host: 'localhost', port: 6379, db: 1 }

        render(text: 'Rate limit exceeded', status: :forbidden) and return unless control.allowed?(request)
      end
    end

### Using as a Rack Middleware in your Rails app

    # config/application.rb

    class Application < Rails::Application
      config.middleware.use RedisKnock::Middleware, limit: 1000, interval: 1.hour, redis: { host: 'localhost', port: 6379, db: 1 }
    end

### Using in your Sinatra app

    # a_sinatra_application.rb

    require 'sinatra'
    require 'redis_knock'

    use RedisKnock::Middleware, limit: 1000, interval: 3600, redis: { host: 'localhost', port: 6379, db: 1 }

    get '/' do
      'Hello World!'
    end

Dependencies
------------

* redis gem
* Redis server version >= 2.1

Installation
------------

### With rubygems:

    $ [sudo] gem install redis_knock

Authors
-------

* Marcelo Correia Pinheiro - <http://salizzar.net/>

License
-------

RedisKnock is free and unencumbered pubic domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.

[rack-throttle]:  https://raw.github.com/datagraph/rack-throttle
[Redis]:          http://redis.io/
[expire]:         http://redis.io/commands/expire

