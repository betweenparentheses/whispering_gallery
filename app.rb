require 'sinatra'
require 'redis'
require 'sanitize'
require 'json'

require_relative './models/message_cache.rb'

configure do
  enable :logging

  heroku_redis = ENV["REDISCLOUD_URL"]
  if heroku_redis
    uri = URI.parse(heroku_redis)
    $redis ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    $redis ||= Redis.new
  end
end


get '/poll_messages.json' do
  MessageCache.new($redis).poll_messages
end

post '/send_message.json' do
  params = JSON.parse(request.env["rack.input"].read)
  message = Sanitize.clean(params['message'])
  cache = MessageCache.new($redis)
  cache.add_message( message )
  return { (Time.now + 21600).utc.to_i => Sanitize.clean(message)}.to_json
end

get '/' do

  # @messages = $redis.zrange "messages", 0, -1, with_scores: true
  # @messages = $redis.zrangebyscore "messages", Time.now.utc.to_i, (Time.now + 21600).utc.to_i, with_scores: true
  # @count = $redis.zcard "messages"


  erb :index
end

