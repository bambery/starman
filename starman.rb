require 'sinatra/assetpack'
require 'dalli'
require 'less'

require File.expand_path('post', File.dirname(__FILE__))
require File.expand_path('helpers', File.dirname(__FILE__))
require File.expand_path('starman_error', File.dirname(__FILE__))

class Starman < Sinatra::Base

  register Sinatra::AssetPack
  helpers CachingHelpers 

  configure do
    set :root, File.dirname(__FILE__)
    set :memcached, Dalli::Client.new
    enable :logging
#    log = File.new("#{settings.root}/log/#{settings.environment}.log", "a+")
#    log.sync = true
#    use Rack::CommonLogger, log 
  end

  configure :development do
#    disable :dump_errors, :raise_errors, :show_exceptions
    disable :dump_errors
    disable :raise_errors, :show_exceptions
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
    logger.info("foo")
    haml :index 
  end

  get '/:section/:name/?' do
    @post = get_or_add_post_to_cache(File.join(params[:section].downcase, params[:name].downcase))
    pass if @post.nil? 
    template = (params[:section].downcase + '_post').to_sym
    haml template, :locals => {:post_content => markdown(@post.content)}
  end

# disable raise_errors and show_exceptions to access this route
  error do
#    logger.info "#{request.env['sinatra.error'].class.name}: #{request.env['sinatra.error'].message}\n #{request.env['sinatra.error'].backtrace.join('\n')}"

    logger.info("#{request.env['sinatra.error'].class.name}: #{request.env['sinatra.error'].message}\n #{request.env['sinatra.error'].backtrace.join("\n")}")
  end

end
