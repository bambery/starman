require 'sinatra/assetpack'
require 'dalli'
require 'less'
require 'redcarpet'

require File.expand_path('post', File.dirname(__FILE__))
require File.expand_path('section', File.dirname(__FILE__))
require File.expand_path('helpers', File.dirname(__FILE__))
require File.expand_path('view_helpers', File.dirname(__FILE__))
require File.expand_path('starman_error', File.dirname(__FILE__))

module Starman
  class App < Sinatra::Base

    register Sinatra::AssetPack
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
    end

    # assetpack config
    assets do 
      css_dir = 'assets/css'
      bootstrap_dir = 'assets/css/bootstrap'
      serve '/css', :from => css_dir

      Less.paths << File.join(App.root, css_dir) << File.join(App.root, bootstrap_dir)

      css :layout, [
        '/css/bootstrap/bootstrap.css', '/css/bootstrap/responsive.css',
        '/css/layout.css'
      ]
      css_compression :less
    end

    get '/' do
      logger.info("foo")
      haml :index 
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
