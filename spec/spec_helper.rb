ENV['RACK_ENV'] = 'test'

#require File.expand_path('../config/boot', File.dirname(__FILE__))
require 'rspec'
require 'rack/test'
require 'capybara/rspec'
require 'factory_girl'
require 'construct'

#Dir[File.expand_path('./support/**/*.rb', __FILE__)].each { |f| require f }
#require_relative './support/helper.rb'
#require_relative '../post.rb'
#require_relative '../starman.rb'
#require_relative '../starman_error.rb'
#require_relative '../helpers.rb'
#require_relative '../section.rb'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Construct::Helpers
  FactoryGirl.find_definitions
  
  # don't pollute stdout with output during tests
  original_stdout = $stdout
  config.before(:all) do 
  # Redirect stderr and stdout
    $stdout = File.new(File.join(File.dirname(__FILE__), 'rspec_output.txt'), 'w')
  end
  config.after(:all) do 
    $stdout = original_stdout
  end

  # Need to unset class instance variables since I move them 
  # around a bit during tests. Gotta keep rspec on its toes.
  def reload_environment
    CloudCrooner.instance_variables.each do |var|
      CloudCrooner.instance_variable_set(var, nil)
    end

    Post.instance_variable_set(:@compiled_content_dir, nil) if defined?(Post)
  end

  def sample_files(construct)
    lambda { |c|
      c.file('public/assets/blog/p1-123.mdown')
      c.file('public/assets/blog/p2-123.mdown')
      c.file('public/assets/blog/p3-123.mdown')
    }.call(construct)
  end

end

