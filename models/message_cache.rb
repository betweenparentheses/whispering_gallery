
require 'json'
class MessageCache

  def initialize(redis)
    @redis = redis
  end


  def poll_messages
    return @redis.zrangebyscore( "messages",
                                 now,
                                 in_thirty_minutes,
                                 with_scores: true ).
                  each_with_object({}) do |entry, hash|
                    hash[ entry[1].to_i ] = entry[0]
                  end.
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