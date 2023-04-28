require 'redis'

module DB
  extend self
  def get(key)
    redis.get(key)
  end

  def set(key, value)
    redis.set(key, value)
  end

  def redis
    @redis ||= Redis.new(url: ENV['REDIS_URL'])
  end
end
