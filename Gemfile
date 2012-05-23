source 'https://rubygems.org'

gem 'rails', '3.2.2'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'devise'
gem 'json'
gem 'resque'
gem 'resque-scheduler'
gem 'thin'
gem 'will_paginate', '~> 3.0'
gem 'apn_on_rails', :git => 'git@github.com:lucascampbell/apn_on_rails.git'
gem 'redis'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :production do
  gem 'pg'
end

group :development, :test do
	gem 'sqlite3'
	gem "rspec-rails", "~> 2.6"
	gem "factory_girl_rails", ">= 3.1.0", :require => 'factory_girl'
	gem "email_spec", ">= 1.2.1"
	gem "capybara", ">= 1.1.2"
	gem "database_cleaner", ">= 0.7.2"
	gem "launchy", ">= 2.1.0"
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
