
require 'json'
class MessageCache

  def initialize(redis)
    @redis = redis
  end

  # returns all messages set to expire
  # in the next 10 minutes
  # in JSON collection form
  def poll_messages
    return @redis.zrangebyscore( "messages",
                                 now,
                                 in_thirty_minutes,
                                 with_scores: true ).
                  map{ |entry| { time: entry[1],
                                 message: entry[0] } }.
                  to_json
  end

  def add_message(text)
    delete_expired
    @redis.zadd "messages",
              new_expiration_score,
              text
  end

  private

  def delete_expired
    @redis.zremrangebyscore "messages", 0, now
  end

  def now
    Time.now.utc.to_i
  end

  def in_thirty_minutes
    now + 1800
  end

  # one hour expiration right now
  def new_expiration_score
    now + 3600
  end

end