require './content.rb'
require './section_proxy.rb'
require File.expand_path('config/boot', File.dirname(__FILE__))
require './starman.rb'

map '/' + CloudCrooner.prefix do
  run CloudCrooner.sprockets
end

map '/' do
  run Starman::App 
end
