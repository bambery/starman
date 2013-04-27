ENV['RACK_ENV'] = 'test'

require File.expand_path('../config/boot', File.dirname(__FILE__))
require 'rspec'
require 'rack/test'
require 'capybara/rspec'
require 'factory_girl'

#Dir[File.expand_path('./support/**/*.rb', __FILE__)].each { |f| require f }
require_relative './support/helper.rb'

# required for testing
def app
  Starman::App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include SectionHelpers
  FactoryGirl.find_definitions
end

