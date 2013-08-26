require './starman.rb'
require File.expand_path('config/boot', File.dirname(__FILE__))

CloudCrooner.sync 

map '/' + CloudCrooner.prefix do
  run CloudCrooner.sprockets
end

map '/' do
  run Starman::App 
end
