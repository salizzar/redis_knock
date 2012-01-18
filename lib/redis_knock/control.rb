# encoding: UTF-8

module RedisKnock
  class Control
    def initialize(options)
      check! options

      @client = get_connection options[:redis]
      @limit = options[:limit]
      @interval = options[:interval]
    end

    def allowed?(request)
      cache_key = get_cache_key request

      count = @client.incr cache_key
      @client.expire(cache_key, @interval) if count == 1

      count <= @limit
    end

    private

    def check!(options)
      raise ArgumentError.new('A limit must be supplied') if options[:limit].nil?
      raise ArgumentError.new('A interval must be supplied') if options[:interval].nil?

      redis_opts = options[:redis]
      raise ArgumentError.new('Redis connection params must be supplied') if redis_opts.nil? || redis_opts.empty?
      raise ArgumentError.new('Redis host must be supplied') if redis_opts[:host].nil?
      raise ArgumentError.new('Redis port must be supplied') if redis_opts[:port].nil?
      raise ArgumentError.new('Redis database must be supplied') if redis_opts[:db].nil?
    end

    def get_connection(options)
      begin
        Redis.new options
      rescue Exception => e
        raise ConnectionError.new("Cannot connect to Redis server: #{e.message}")
      end
    end

    def get_cache_key(request)
      request.ip.to_s
    end
  end
end

