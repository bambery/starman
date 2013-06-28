source 'https://rubygems.org'
ruby "1.9.3"

gem 'sinatra', "~> 1.4.2"
gem 'thin'

group :assets do 
  gem 'asset_sync'
  gem 'haml'
  gem 'sass'
  gem 'therubyracer'
  gem 'redcarpet'
  gem 'fog', '~> 1.12.1'
end

# sinatra helpers
gem 'sinatra-partial'

# memcached
gem 'memcachier'
gem 'dalli'
gem 'kgio'

gem 'rake'

group :test, :development do
  gem 'cucumber'
  gem 'rspec'
  gem 'capybara'
  gem 'factory_girl'
  gem 'shotgun'
end
