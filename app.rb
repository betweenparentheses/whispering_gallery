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

  heroku_redis = ENV["REDISCLOUD_URL"]
  if heroku_redis
    uri = URI.parse(heroku_redis)
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    redis = Redis.new
  end



  Thread.current['sockets'] = []

  redis.subscribe 'whispers' do |on|
    on.message do |channel, message|
      Thread.current['sockets'].each do |s|
        s.send message
      end
    end
  end
end)


get '/whisper' do
  if request.websocket?
    cache = MessageCache.new($redis)
    request.websocket do |ws|
      ws.onopen do
        ws.send("We're whispering!")
        settings.watcher['sockets'] << ws
      end
      ws.onmessage do |msg|
        if msg == "/refresh/"
          $redis.publish 'whispers', cache.poll_messages
        else
          $redis.publish 'whispers', "/sent/"
          cache = MessageCache.new($redis)
          cache.add_message( msg )
        end
      end
      ws.onclose do
        warn('websocket has been closed')
        settings.watcher['sockets'].delete(ws)
      end
    end
  else
    # forbidden for non-websocket requests
    render 403
  end
end


get '/about' do
  erb :about, layout: false
end



get '/' do

  erb :index

end

