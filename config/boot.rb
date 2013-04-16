require 'rubygems'
require 'bundler'
require 'sinatra/base'
require 'date'

Bundler.setup

require File.expand_path('../starman', File.dirname(__FILE__))
 
root_dir = File.expand_path('..', File.dirname(__FILE__))

log = File.new("#{root_dir}/log/starman-#{ENV['RACK_ENV']}-#{Date.today.month}-#{Date.today.day}-#{Date.today.year}.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

ENV['POSTS_DIR'] = 'content'



