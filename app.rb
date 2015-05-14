require 'sinatra'
require 'redis'
require 'sanitize'
require 'json'

require_relative './models/message_cache.rb'

configure do
  enable :logging
end

# configure do
#   require 'redis'
#   uri = URI.parse(ENV["REDISCLOUD_URL"])
#   $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
# end

$redis = Redis.new


# integer formatted expiration time in 6 hours
def new_expiration
  ( Time.now + 21600).to_i
end


get '/poll_messages.json' do
  MessageCache.new.poll_messages
end

post '/send_message.json' do
  params = JSON.parse(request.env["rack.input"].read)
  message = Sanitize.clean(params['message'])
  cache = MessageCache.new
  cache.add_message( message )
  return { (Time.now + 21600).utc.to_i => Sanitize.clean(message)}.to_json
end

get '/' do
  $redis.zadd "messages", ( Time.now + 21600).utc.to_i, "blah"
  $redis.zadd "messages", ( Time.now + 21600).utc.to_i, "bleh"
  $redis.zadd "messages", ( Time.now + 21600).utc.to_i, "bloh"
  $redis.zadd "messages", ( Time.now + 21600).utc.to_i, "ffsadj"
  # @messages = $redis.zrange "messages", 0, -1, with_scores: true
  @messages = $redis.zrangebyscore "messages", Time.now.utc.to_i, (Time.now + 21600).utc.to_i, with_scores: true
  @count = $redis.zcard "messages"


  erb :index
end

