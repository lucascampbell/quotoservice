# Load the rails application
require File.expand_path('../application', __FILE__)
require 'resque'
require 'resque_scheduler'
require 'apn_on_rails'

resque_file =  File.expand_path(File.join(File.dirname(__FILE__),'resque_schedule.yml'))
Resque.redis = "redis://redistogo:7c19be812d96996defafd43d673ac96a@lab.redistogo.com:9393/"
Resque.schedule = YAML.load_file(resque_file)
# Initialize the rails application
QuotesService::Application.initialize!
