require 'rspec/core/rake_task'
require 'rake'
require 'asset_sync'
require 'sprockets'
#require './starman'


RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

AssetSync.configure do |config|
  config.fog_provider = 'AWS'
  config.fog_directory = ENV['FOG_DIRECTORY']
  config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
  config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.prefix = "assets"
  config.public_path = Pathname("./public")
end

namespace :assets do
  desc 'Precompile assets and upload to S3'
  task :precompile do 
#    Rake::SprocketsTask.new do |t|
#      t.environment = Sprockets::Environment.new
#      t.output = "./public/assets"
#      t.assets = %w( layout.scss )
#    target = Pathname('./public/assets')
#    manifest = Sprockets::Manifest.new(sprockets, './public/assets/manifest.json')
#
#    sprockets.each_logical_path do |logical_path|
#      if (!File.extname(logical_path).in?(['.js', '.css']) || logical_path =~ /application\.(css|js)$/) && asset = sprockets.find_asset(logical_path)
#        filename = target.join(logical_path)
#        FileUtils.mkpath(filename.dirname)
#        puts "Write asset: #{filename}"
#        asset.write_to(filename)
#        manifest.compile(logical_path)
#      end
#    end
    sh 'sass --style compressed assets/css/sass/layout.scss assets/css/layout.css'
  end
end

#    AssetSync.sync
#  end
#end

