require 'sinatra'
require 'mongo'
#require 'securerandom'
require 'erb'
require 'sinatra/base'

class Helpdesk < Sinatra::Base
  #Dont enable :sessions because it adds Rack::Session::Cookie to the stack
  use Rack::Session::Pool

  def initialize()
    super()
    @db = Mongo::Client.new(['127.0.0.1:27017'], :database => 'helpdesk')
    #@db = Mongo::Client.new('mongodb://127.0.0.1:27017/helpdesk')
  end

  def is_user_logged_in
    return session[:username] != nil && session[:username] != ''
  end

  def init_ctx
    @username = session[:username]
  end

  get '/' do
    self.init_ctx
    erb :index
  end

  get '/help-me' do
    self.init_ctx
    erb :helpme
  end

  def generate_code()
    @params[:code] = Array.new(5){rand(36).to_s(36)}.join.downcase
    code_exist = @db[:requests].find('code' => @params[:code]).count()
    while code_exist > 0
      @params[:code] = Array.new(5){rand(36).to_s(36)}.join.downcase
      code_exist = @db[:requests].find('code' => @params[:code]).count()
    end
  end

  post '/help-me' do
    self.init_ctx
    self.generate_code

    @params[:status] = 'New'
    @params[:updatedat] = @params[:createdat] = Time.now.strftime('%Y-%m-%d %H:%M:%S %z')
    @params[:myguid] = SecureRandom.uuid
    @db[:requests].insert_one @params
    @db.close
    redirect '/'
  end

  get '/login' do
    self.init_ctx
    erb :login
  end

  post '/login' do
    self.init_ctx
    if @params[:id] == 'admin' && @params[:pw] == 'admin'
      session[:username] = 'admin'
      redirect '/'
    else
      redirect '/login?msg=Invalid+login'
    end
  end

  get '/logout' do
    self.init_ctx
    session[:username] = nil
    redirect '/'
  end

  get '/tickets-list' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end
    @list = @db[:requests].find()
    erb :ticketslist
  end
end


if __FILE__ == $0
  Helpdesk.run!
end