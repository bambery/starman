require 'memcachier'
require 'dalli'
require 'sass'
require 'redcarpet'

require File.expand_path('post', File.dirname(__FILE__))
require File.expand_path('section', File.dirname(__FILE__))
require File.expand_path('helpers', File.dirname(__FILE__))
require File.expand_path('view_helpers', File.dirname(__FILE__))
require File.expand_path('starman_error', File.dirname(__FILE__))

module Starman
  class App < Sinatra::Base

    helpers Starman::CachingHelpers 
    helpers Starman::LogHelpers 
    helpers Starman::PostHelpers

    configure do
      set :root, File.dirname(__FILE__)
      set :memcached, Dalli::Client.new
      enable :logging
  #    disable :dump_errors, :raise_errors, :show_exceptions
  #    log = File.new("#{settings.root}/log/#{settings.environment}.log", "a+")
  #    log.sync = true
  #    use Rack::CommonLogger, log 
      #    look for sass in assets/css, and compile it into css in public/assets/css
      set :scss, :views => "#{settings.root}/assets/css"
    end
    
    configure :development, :test do
      require_relative('config/dev-aw3-config')
      #enable :use_s3 
      disable :use_s3 
      set :asset_host, "s3-#{ENV['FOG_REGION']}.amazonaws.com"
      set :fog_directory, "#{ENV['FOG_DIRECTORY']}"
    end

    configure :production do
      enable :use_s3 
      set :asset_host, "#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com/assets"
    end

    get '/css/:name.css' do 
      if settings.use_s3?
        #grab the precompiled css from s3 
        p File.join(settings.asset_host, settings.fog_directory, "assets", "css", params[:name] + ".css")
        send_file File.join(settings.asset_host, settings.fog_directory, "assets", "css", params[:name] + ".css")
      else
        scss params[:name].to_sym
      end
    end

    get '/' do
      haml :index 
    end

    get '/section' do
      haml :section
    end

    get '/:section/:name.?:format?' do
      begin 
        @post = get_or_add_post_to_cache(File.join(params[:section].downcase, params[:name].downcase))
      rescue StarmanError => e
        add_error_to_log(e)
        pass
      else
        template = (params[:section].downcase + '_post').to_sym
        haml template, :locals => {:post_content => markdown(@post.content)}
      end
    end

    get '/:section/?' do
      begin
        @section_posts = get_or_add_section_to_cache(params[:section].downcase)
      rescue StarmanError => e
        add_error_to_log(e)
        pass
      else
        haml params[:section].downcase.to_sym
      end
    end

  end
end
