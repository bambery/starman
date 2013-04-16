require 'sinatra/base'
require 'sinatra/assetpack'
require 'dalli'
require 'less'

require File.expand_path('post', File.dirname(__FILE__))
require File.expand_path('helpers.rb', File.dirname(__FILE__))

class Starman < Sinatra::Base

  register Sinatra::AssetPack
  helpers CachingHelpers 

  configure do
    set :root, File.dirname(__FILE__)
    set :memcached, Dalli::Client.new
    enable :logging
  end

  configure :development do
    enable :dump_errors, :raise_errors, :show_exceptions
  end

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

  get '/:section/:name/?' do
    @post = get_or_add_post_to_cache(File.join(params[:section].downcase, params[:name].downcase))
    pass if @post.nil? 
    template = (params[:section].downcase + '_post').to_sym
    haml template, :locals => {:post_content => markdown(@post.content)}
  end

end
