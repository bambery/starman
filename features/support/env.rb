ENV['ENV_RACK'] = 'test'

require File.expand_path('../../config/boot', File.dirname(__FILE__))
require 'factory_girl'
require 'capybara'
require 'rspec'
require 'cucumber/rspec/doubles'

Capybara.app = Starman

class StarmanWorld
  include Capybara::DSL
  include RSpec::Expectations

  FactoryGirl.find_definitions

  def app
    Starman
  end
end

World do
  StarmanWorld.new
end
