require 'memcachier'
require 'dalli'
require 'sass'
require 'sinatra/base'
require 'sinatra/sprockets-helpers'
require 'redcarpet'

require File.expand_path('post', File.dirname(__FILE__))
require File.expand_path('section', File.dirname(__FILE__))
require File.expand_path('helpers', File.dirname(__FILE__))
require File.expand_path('view_helpers', File.dirname(__FILE__))
require File.expand_path('starman_error', File.dirname(__FILE__))
require File.expand_path('section_proxy', File.dirname(__FILE__))
require File.expand_path('content', File.dirname(__FILE__))

module Starman
  class App < Sinatra::Base

    helpers do
      include Starman::CachingHelpers 
      include Starman::LogHelpers 
      include Starman::PostHelpers
      include Sprockets::Helpers
    end

    configure do
      set :root, File.dirname(__FILE__)
      set :memcached, Dalli::Client.new
      enable :logging
  #    disable :dump_errors, :raise_errors, :show_exceptions
  #    log = File.new("#{settings.root}/log/#{settings.environment}.log", "a+")
  #    log.sync = true
  #    use Rack::CommonLogger, log 
      #Sprockets::Helpers.configure do |config|
      #  config.default_path_options[:stylesheet_path][:dir] = 'css'
      #end
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
        @section = get_or_add_section_to_cache(params[:section].downcase)
      rescue StarmanError => e
        add_error_to_log(e)
        pass
      else
        haml params[:section].downcase.to_sym
      end
    end

  end
end
