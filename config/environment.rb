# Load the rails application
require File.expand_path('../application', __FILE__)
require 'resque'
require 'resque_scheduler'
require 'resque_scheduler/server'
require 'apn_on_rails'
require 'c2dm_on_rails'
require 'uri'

resque_file =  File.expand_path(File.join(File.dirname(__FILE__),'resque_schedule.yml'))
ENV["REDISTOGO_URL"] ||= "redis://redistogo:ef7b93c9efa962a832a49c8435de7b95@scat.redistogo.com:9034"

uri = URI.parse(ENV["REDISTOGO_URL"])
#REDIS = 
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

Resque.schedule = YAML.load_file(resque_file)
# Initialize the rails application
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
QuotesService::Application.initialize!
