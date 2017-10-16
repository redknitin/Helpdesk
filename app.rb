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
    @datetimefmt = '%Y-%m-%d %H:%M:%S'
    #@datetimefmt = '%Y-%m-%d %H:%M:%S %z'

    @departments = [
        {:org => 'Apache Foundation', :dept => ['Software Development', 'Quality Control']},
        {:org => 'Canonical', :dept => ['System Administration', 'Marketing']}
    ]
  end

  def is_user_logged_in
    return session[:username] != nil && session[:username] != ''
  end

  def init_ctx
    @username = session[:username]
    @rolename = session[:rolename]
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
    @params[:updatedat] = @params[:createdat] = Time.now.strftime(@datetimefmt)
    @params[:myguid] = SecureRandom.uuid
    if @username != nil && @username != ''
      @params[:createdby] = @params[:updatedby] = @username
    end
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
      session[:rolename] = 'admin'
    elsif @params[:id] == 'helpdesk' && @params[:pw] == 'helpdesk'
      session[:rolename] = 'helpdesk'
    elsif @params[:id] == 'requester01' && @params[:pw] == 'requester01'
      session[:rolename] = 'requester'
    elsif @params[:id] == 'requester02' && @params[:pw] == 'requester02'
      session[:rolename] = 'requester'
    else
      redirect '/login?msg=Invalid+login'
      return #redirect is supposed to stop execution of this method, but just to be sure
    end
    session[:username] = @params[:id]
    redirect '/'
  end

  get '/logout' do
    #self.init_ctx
    session[:username] = session[:rolename] = nil
    @username = @rolename = nil
    redirect '/'
  end

  get '/tickets-list' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @list = @db[:requests].find('createdby' => @username)
    else
      @list = @db[:requests].find()
    end

    erb :ticketslist
  end

  post '/ticket-status' do
    self.init_ctx

    @record = @db[:requests].find('code' => @params[:code]).limit(1).first;

    @record[:updatedat] = Time.now.strftime(@datetimefmt)
    @record[:updatedby] = @username
    @record[:status] = @params[:status]

    @db[:requests].update_one(
        {'code' => params[:code]},
        @record,
        {:upsert => false}
    )

    @db.close

    redirect '/tickets-list'
  end
end


if __FILE__ == $0
  Helpdesk.run!
end