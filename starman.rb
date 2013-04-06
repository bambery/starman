require 'sinatra/base'
require 'sinatra/assetpack'
require 'dalli'
require 'less'

class Starman < Sinatra::Base

  set :root, File.dirname(__FILE__)
  set :memcached, Dalli::Client.new

  register Sinatra::AssetPack

  # assetpack config
  assets do 
    css_dir = 'assets/css'
    bootstrap_dir = 'assets/css/bootstrap'
    serve '/css', :from => css_dir

    Less.paths << File.join(Starman.root, css_dir) << File.join(Starman.root, bootstrap_dir)

    css :layout, [
      '/css/bootstrap/bootstrap.css', '/css/bootstrap/responsive.css',
      '/css/layout.css'
    ]
    css_compression :less
  end

  get '/' do
    haml :index 
  end

end
