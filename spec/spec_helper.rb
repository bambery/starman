ENV['RACK_ENV'] = 'test'

require 'starman'
require 'rspec'
require 'rack/test'
require 'capybara/rspec'

def app
  Starman
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

