require 'sinatra'

module Starman
  class App < Sinatra::Base
    get '/' do
      'hello world!'
    end
  end
end
