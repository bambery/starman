require 'rake'
require './config/boot.rb'
require 'sprockets-sass'
require 'sass/plugin/rack'

RSpec::Core::RakeTask.new(:spec)

namespace :assets do
  desc 'compile assets'
  task :sync do
    CloudCrooner.assets_to_compile = ['layout.css']
  end
end
