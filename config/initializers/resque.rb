require 'resque/scheduler'
require 'resque/scheduler/server'
require 'resque-retry'
require 'resque-retry/server'
require 'resque/status_server'

# Point it to redis to go on heroku environments
if ENV["REDIS_URL"].present?
  uri = URI.parse(ENV["REDIS_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
else
  Resque.redis = Redis.new
end

require 'resque/failure/redis'
Resque::Failure::MultipleWithRetrySuppression.classes = [Resque::Failure::Redis]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

Resque.logger.level = Logger::INFO
