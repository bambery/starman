ENV['RACK_ENV'] = 'test'

#require File.expand_path('../starman', File.dirname(__FILE__))
require File.expand_path('../config/boot', File.dirname(__FILE__))
require 'rspec'
require 'rack/test'
require 'capybara/rspec'

def app
  Starman
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

