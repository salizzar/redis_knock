# encoding: UTF-8

require 'spec_helper'

describe RedisKnock::Control do
  let(:subject)       { RedisKnock::Control }
  let(:host)          { 'localhost' }
  let(:port)          { 6379 }
  let(:db)            { 1 }
  let(:interval)      { 3600 }
  let(:limit)         { 1000 }
  let(:ip)            { '127.0.0.1' }
  let(:request)       { mock(:ip => ip) }
  let(:redis_client)  { mock 'An Redis connection' }
  let(:redis_options) { { :host => host, :port => port, :db => db } }
  let(:options)       { { :limit => limit, :interval => interval, :redis => redis_options } }

  describe 'converting hash keys to symbols' do
    it 'serializes all attributes recursively' do
      args = { 'limit' => limit, 'interval' => interval, 'redis' => { 'host' => host, 'port' => port, 'db' => db } }

      Redis.should_receive(:new).with(redis_options).and_return(redis_client)

      control = subject.new args
      control.instance_variable_get('@limit').should == limit
      control.instance_variable_get('@interval').should == interval
    end
  end

  describe 'invalid arguments validation' do
    it 'raises ArgumentError if limit is not informed' do
      options.delete :limit

      error = ArgumentError.new 'A limit must be supplied'
      expect { subject.new options }.to raise_error(error.class, error.message)
    end

    it 'raises ArgumentErroro if interval is not informed' do
      options.delete :interval

      error = ArgumentError.new 'A interval must be supplied'
      expect { subject.new options }.to raise_error(error.class, error.message)
    end

    context 'Redis connection params' do
      it 'raises ArgumentError if redis connection params are not informed' do
        options.delete :redis

        error = ArgumentError.new 'Redis connection params must be supplied'
        expect { subject.new options }.to raise_error(error.class, error.message)
      end

      it 'raises ArgumentError if host is not informed' do
        redis_options.delete :host

        error = ArgumentError.new 'Redis host must be supplied'
        expect { subject.new options }.to raise_error(error.class, error.message)
      end

      it 'raises ArgumentError if port is not informed' do
        redis_options.delete :port

        error = ArgumentError.new 'Redis port must be supplied'
        expect { subject.new options }.to raise_error(error.class, error.message)
      end

      it 'raises ArgumentError if database is not informed' do
        redis_options.delete :db

        error = ArgumentError.new 'Redis database must be supplied'
        expect { subject.new options }.to raise_error(error.class, error.message)
      end
    end
  end

  describe 'when cannot connect to Redis server' do
    it 'raises ConnectionError' do
      Redis.should_receive(:new).and_raise('An error')

      error = RedisKnock::ConnectionError.new 'Cannot connect to Redis server: An error'
      expect { subject.new options }.to raise_error(error.class, error.message)
    end
  end

  describe 'checking for allowed requests' do
    before :each do
      Redis.should_receive(:new).with(redis_options).and_return(redis_client)
    end

    it 'expires key if is first request' do
      redis_client.should_receive(:incr).and_return(1)
      redis_client.should_receive(:expire).with(ip, interval)

      control = subject.new options
      control.should be_allowed(request)
    end

    it 'returns true when limit is not reached' do
      redis_client.should_not_receive(:expire)
      redis_client.should_receive(:incr).and_return(limit - 1)

      control = subject.new options
      control.should be_allowed(request)
    end

    it 'returns false when limit is reached' do
      redis_client.should_not_receive(:expire)
      redis_client.should_receive(:incr).and_return(limit + 1)

      control = subject.new options
      control.should_not be_allowed(request)
    end
  end
end

