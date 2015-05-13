require 'sinatra'

# configure do
#   require 'redis'
#   uri = URI.parse(ENV["REDISCLOUD_URL"])
#   $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
# end

get '/' do
  erb :index
end