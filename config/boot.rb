require 'rubygems'
require 'bundler'
require 'sinatra/base'
require 'date'

Bundler.setup

root_dir = File.expand_path('..', File.dirname(__FILE__))
require File.expand_path('starman', root_dir)
 

if ENV['RACK_ENV'] != "test" 
  log = File.new("#{root_dir}/log/starman-#{ENV['RACK_ENV']}-#{Date.today.month}-#{Date.today.day}-#{Date.today.year}.log", "a+")
  $stdout.reopen(log)
  $stderr.reopen(log)
end

ENV['POSTS_DIR'] = 'content'
ENV['TEST_MEMCACHED_SERVER'] = '127.0.0.1:11211'



