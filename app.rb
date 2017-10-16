require 'sinatra'
#require 'mongo'
#require 'securerandom'
require 'erb'
require 'sinatra/base'

#Dont enable :sessions because it adds Rack::Session::Cookie to the stack
use Rack::Session::Pool

class Helpdesk < Sinatra::Base
  def is_user_logged_in
    return session[:username] != nil && session[:username] != ''
  end

  get '/' do
    @username = session[:username]
    erb :index
  end

  get '/help-me' do
    erb :helpme
  end

  post '/help-me' do
    redirect '/'
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    redirect '/'
  end

  get '/logout' do
    redirect '/'
  end

  get '/tickets-list' do
    if !self.is_user_logged_in()
      redirect '/'
    end
    redirect '/'
  end
end


if __FILE__ == $0
  Helpdesk.run!
end