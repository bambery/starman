ENV['RACK_ENV'] = 'test'

require File.expand_path('../config/boot', File.dirname(__FILE__))
require 'rspec'
require 'rack/test'
require 'capybara/rspec'
require 'factory_girl'

# required for testing
def app
  Starman::App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  FactoryGirl.find_definitions
end

