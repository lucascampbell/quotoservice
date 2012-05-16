# Load the rails application
require File.expand_path('../application', __FILE__)
require 'resque'
require 'resque_scheduler'
resque_file =  File.expand_path(File.join(File.dirname(__FILE__),'config','resque_schedule.yml'))
Resque.redis = "redis://redistogo:ec4a3f060076874728331f6378f6fd70@ray.redistogo.com:9067/"
Resque.schedule = YAML.load_file(resque_file)
# Initialize the rails application
QuotesService::Application.initialize!
