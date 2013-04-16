require 'rubygems'
require 'bundler'
require 'sinatra/base'
Bundler.setup

require File.expand_path('../starman', File.dirname(__FILE__))

ENV['POSTS_DIR'] = 'content'


