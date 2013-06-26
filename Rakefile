require 'rspec/core/rake_task'
require 'rake'
require 'asset_sync'
require 'sass/plugin/rack'
require_relative 'config/dev-aw3-config'

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

AssetSync.configure do |config|
  config.fog_provider = 'AWS'
  config.fog_region = 'us-west-2'
  config.fog_directory = ENV['FOG_DIRECTORY']
  config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
  config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.prefix = "assets"
  config.public_path = Pathname("./public")
end

namespace :assets do
  desc 'Precompile assets and upload to S3'
  task :precompile do 

    # compile sass and store the css in assets/css if they have been changed since the last compilation 
    Sass::Plugin.options[:cache] = :false
    Sass::Plugin.options[:style] = :compressed
    Sass::Plugin.options[:template_location] = "#{File.dirname(__FILE__)}/assets/css/sass"
    Sass::Plugin.options[ :css_location ] = "#{File.dirname(__FILE__)}/assets/css"
    Sass::Plugin.update_stylesheets

    # upload to S3
    AssetSync.sync
  end
end

