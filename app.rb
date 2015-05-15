require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra-websocket'
require 'redis'
require 'sanitize'
require 'json'

require_relative './models/message_cache.rb'

set :server, 'thin'


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

set(:watcher, Thread.new do
  redis = Redis.new
  Thread.current['sockets'] = []

  redis.subscribe 'whispers' do |on|
    on.message do |channel, message|
      Thread.current['sockets'].each do |s|
        s.send message
      end
    end
  end
end)

get '/socket' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        ws.send("Hello World!")
        settings.watcher['sockets'] << ws
      end
      ws.onmessage do |msg|
        $redis.publish 'foobar', msg
      end
      ws.onclose do
        warn('websocket has been closed')
        settings.watcher['sockets'].delete(ws)
      end
    end
  else
    erb :socket
  end
end


# get '/poll_messages.json' do
#   MessageCache.new($redis).poll_messages
# end

# post '/send_message.json' do
#   params = JSON.parse(request.env["rack.input"].read)
#   message = Sanitize.clean(params['message'])
#   cache = MessageCache.new($redis)
#   cache.add_message( message )
#   return { (Time.now + 21600).utc.to_i => Sanitize.clean(message)}.to_json
# end

get '/' do

  # @messages = $redis.zrange "messages", 0, -1, with_scores: true
  # @messages = $redis.zrangebyscore "messages", Time.now.utc.to_i, (Time.now + 21600).utc.to_i, with_scores: true
  # @count = $redis.zcard "messages"

  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        ws.send("We're whispering!")
        settings.watcher['sockets'] << ws
      end
      ws.onmessage do |msg|
        $redis.publish 'whispers', "*WHISPER SENT*"
        cache = MessageCache.new($redis)
        cache.add_message( msg )
      end
      ws.onclose do
        warn('websocket has been closed')
        settings.watcher['sockets'].delete(ws)
      end
    end
  else
    erb :index
  end

end

