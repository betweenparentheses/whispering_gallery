require 'redis'
require 'json'
class MessageCache

  def initialize
    heroku_redis = ENV["REDISCLOUD_URL"]
    if heroku_redis
      uri = URI.parse(heroku_redis)
      $redis ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    else
      $redis ||= Redis.new
    end
    @redis = $redis
  end

  # returns all messages set to expire
  # in the next 10 minutes
  # in JSON collection form
  def poll_messages
    return @redis.zrangebyscore( "messages",
                                 now,
                                 in_ten_minutes,
                                 with_scores: true ).
                  map{ |entry| { time: entry[1],
                                 message: entry[0] } }.
                  to_json
  end

  def add_message(text)
    @redis.zadd "messages",
              new_expiration_score,
              text
  end

  private

  def now
    Time.now.utc.to_i
  end

  def in_ten_minutes
    now + 600
  end

  def new_expiration_score
    (Time.now + 15).utc.to_i
  end

end