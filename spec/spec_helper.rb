# encoding: UTF-8

require 'bundler'
require 'rspec'
require 'rack/test'
require 'redis_knock'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def get_app
    @app ||= mock 'An app'
  end
end
