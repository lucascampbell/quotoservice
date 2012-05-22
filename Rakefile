#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

QuotesService::Application.load_tasks

require 'resque'
require 'resque_scheduler'
require 'resque/tasks'
require 'resque_scheduler/tasks'
task "resque:setup" do |t, args|
  require File.join(File.dirname(__FILE__),'config/environment')
  require 'resque'
  require 'resque_scheduler'
  require 'resque/tasks'
  require 'resque_scheduler/tasks'
  ENV['QUEUE'] = 'push_job'
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end

task "jobs:work" => "resque:work"

desc "run resque jobs for update queue"
task :run do  |t|
  sh "rake resque:work"
end

begin
   require 'apn_on_rails_tasks'
rescue MissingSourceFile => e
   puts e.message
end