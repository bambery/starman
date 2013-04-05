require 'sinatra/base'

class Starman < Sinatra::Base

  set :root, File.dirname(__FILE__)

  set :memcached, Dalli::Client.new

  # using less for stylesheets
  set :less, :views => 'assets/less'
  Less.paths << "#{Starman.root}/assets/less"

  get '/' do
    'moop'
  end

  # use less for css
  get '/css/:style.css' do
    less params[:style].to_sym
  end


end
