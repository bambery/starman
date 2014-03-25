require 'rubygems'
require 'bundler'
require 'cloud_crooner'
require 'sprockets-sass'
require 'date'

Bundler.setup

#root_dir = File.expand_path('..', File.dirname(__FILE__))
#require File.expand_path('starman', root_dir)

#if ENV['RACK_ENV'] != "test" 
#  log = File.new("#{root_dir}/log/starman-#{ENV['RACK_ENV']}-#{Date.today.month}-#{Date.today.day}-#{Date.today.year}.log", "a+")
#  $stdout.reopen(log)
# $stderr.reopen(log)
#end

ENV['POSTS_DIR'] = 'content'

ENV['TEST_MEMCACHED_SERVER'] = '127.0.0.1:11211'

CloudCrooner.configure do |config|
  config.serve_assets = "remote"
  config.asset_paths = %w( assets content )
  config.assets_to_compile = %w( stylesheets/layout.css blog/baz.mdown )
end

Starman::SectionProxy.create_section_proxies
CloudCrooner.sync
