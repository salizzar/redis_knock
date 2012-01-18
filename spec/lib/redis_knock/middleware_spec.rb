# encoding: UTF-8

require 'spec_helper'

describe RedisKnock::Middleware do
  let(:redis_options) { { :host => 'localhost', :port => 6379, :db => 1 } }
  let(:options)       { { :limit => 1000, :interval => 3600, :redis => redis_options } }
  let(:target_app)    { get_app }
  let(:app)           { RedisKnock::Middleware.new target_app, options }
  let(:control)       { mock 'A Redis Throttle Control' }

  context 'performing throttle check' do
    before :each do
      RedisKnock::Control.should_receive(:new).and_return(control)
    end

    context 'with a allowed request' do
      it 'process if limit is not reached' do
        target_app.should_receive(:call).and_return([ 200, {}, [ 'An response body' ] ])
        control.should_receive(:allowed?).and_return(true)

        get '/'
        last_response.status.should == 200
        last_response.body.should == 'An response body'
      end
    end

    context 'with a not allowed request' do
      before :each do
        control.should_receive(:allowed?).and_return(false)
      end

      it 'returns HTTP 403 Forbidden if limit was reached' do
        get '/'
        last_response.status.should == 403
        last_response.body.should == 'Rate limit exceeded'
      end

      it 'returns content-type and retry-after HTTP headers when is not allowed' do
        get '/'
        last_response.headers['Content-Type'].should == 'text/plain; charset=utf-8'
        last_response.headers['Content-Length'].should == 'Rate limit exceeded'.length.to_s
      end
    end
  end
end

