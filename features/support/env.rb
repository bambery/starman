ENV['RACK_ENV'] = 'test'

require File.expand_path('../../config/boot', File.dirname(__FILE__))
require 'factory_girl'
require 'capybara'
require 'rspec'
require 'cucumber/rspec/doubles'

Capybara.app = Starman::App

class StarmanWorld
  include Capybara::DSL
  include RSpec::Expectations

  FactoryGirl.find_definitions

  def app
    Starman::App
  end
end

World do
  StarmanWorld.new
end
