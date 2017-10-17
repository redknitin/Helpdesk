require 'sinatra'
require 'mongo'
#require 'securerandom'
require 'erb'
require 'sinatra/base'
require 'digest/sha1'

class Helpdesk < Sinatra::Base
  use Rack::Session::Pool #Dont "enable :sessions" because it adds Rack::Session::Cookie to the stack but we want Rack::Session::Pool instead

  #Initialize data needed for the application
  def initialize()
    super()
    @db = Mongo::Client.new(['127.0.0.1:27017'], :database => 'helpdesk') #The URL notation helps reduce this to a single config setting Eg. Mongo::Client.new('mongodb://127.0.0.1:27017/helpdesk')
    @datetimefmt = '%Y-%m-%d %H:%M:%S' #Add %z for timezone; make this a configuration option

    #Currently, anything that is hardcoded but needs to be moved into master data can be defined here as, for example, an array or dictionary
    @departments = [
        {:org => 'Apache Foundation', :dept => ['Software Development', 'Quality Control']},
        {:org => 'Canonical', :dept => ['System Administration', 'Marketing']}
    ]
    @statuses = ['New', 'Assigned', 'Suspended', 'Completed', 'Cancelled']

    @pagesize = 3
  end

  #Checks if the username session value has been set
  def is_user_logged_in
    return session[:username] != nil && session[:username] != ''
  end

  #Initializes members variables based on session values, parameters, and other context data
  def init_ctx
    @username = session[:username]
    @rolename = session[:rolename]
  end

  #Home page of the application
  get '/' do
    self.init_ctx
    appsetup() #Check if the app needs first-time setup
    erb :index
  end

  #Display the new trouble ticket form
  get '/help-me' do
    self.init_ctx
    erb :helpme
  end

  #Creates an alphanumeric code for identifying the trouble ticket
  def generate_code()
    @params[:code] = Array.new(5){rand(36).to_s(36)}.join.downcase
    code_exist = @db[:requests].find('code' => @params[:code]).count()
    while code_exist > 0
      @params[:code] = Array.new(5){rand(36).to_s(36)}.join.downcase
      code_exist = @db[:requests].find('code' => @params[:code]).count()
    end
  end

  #Creates the new trouble ticket
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

  #Initializes the application for first-time use
  def appsetup()
    #If the database has no users, create the admin user with defaults
    if @db[:users].count == 0
      recuser = {
          :username => 'admin',
          :password => Digest::SHA1.hexdigest('admin'),
          :rolename => 'admin',
          :email => 'root@localhost',
          :islocked => 'false'
      }

      @db[:users].insert_one recuser
    end
  end

  #Displays the login page
  get '/login' do
    self.init_ctx
    #if @params[:msg] != nil && @params[:msg] != ''
    #  @msg = @params[:msg]
    #end
    erb :login
  end

  #Process login inputs
  post '/login' do
    self.init_ctx

    usr = @db[:users].find(
        'username' => @params[:id],
        'password' => Digest::SHA1.hexdigest(@params[:pw]),
        'islocked' => 'false'
    ).limit(1).first
    session[:rolename] = usr[:rolename]
    session[:username] = usr[:username]

    if usr == nil
      redirect '/login?msg=Invalid+login'
      return #redirect is supposed to stop execution of this method, but just to be sure
    end

    redirect '/'
  end

  #Logout the user by clearing session information
  get '/logout' do
    #self.init_ctx
    session[:username] = session[:rolename] = nil
    @username = @rolename = nil
    redirect '/'
  end

  #List all trouble tickets
  get '/tickets-list' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    @skip = 0
    if @skip != nil && @skip != ''
      @skip = @params[:skip].to_i
    end

    @totalrowcount = 0
    if @rolename == 'requester'
      @totalrowcount = @list = @db[:requests].find('createdby' => @username).count()
      @list = @db[:requests].find('createdby' => @username).skip(@skip).limit(@pagesize)
    else
      #Helpdesk agents and admins can view the statuses of all requests
      @totalrowcount = @list = @db[:requests].count()
      @list = @db[:requests].find().skip(@skip).limit(@pagesize)
    end

    erb :ticketslist
  end

  #Change the ticket status
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

  #Get info about a single trouble ticket
  get '/ticket-detail/:code' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:code]).limit(1).first
    else
      @rec = @db[:requests].find('code' => @params[:code]).limit(1).first
    end

    erb :ticketdetail
  end

  #List all users
  get '/users-list' do
    self.init_ctx
    #check if role is admin
    if !self.is_user_logged_in() || @rolename != 'admin'
      redirect '/'
      return #Does execution stop with a redirect, or do we need a return in this framework?
    end

    @skip = 0
    if @skip != nil && @skip != ''
      @skip = @params[:skip].to_i
    end

    @totalrowcount = 0
    @totalrowcount = @list = @db[:users].count()
    @list = @db[:users].find().skip(@skip).limit(@pagesize)

    erb :userslist
  end

  #Create a user account
  post '/user-save' do
    self.init_ctx
    #check if role is admin before saving
    if !self.is_user_logged_in() || @rolename != 'admin'
      redirect '/'
      return #Does execution stop with a redirect, or do we need a return in this framework?
    end

    recuser = {
        :username => @params[:id],
        :password => Digest::SHA1.hexdigest(@params[:pw]),
        :rolename => @params[:rolename],
        :email => @params[:email],
        :islocked => 'false'
    }

    cnt = @db[:users].find('username' => @params[:id]).count()
    if cnt == 0
      @db[:users].insert_one recuser
      @db.close
    else
      #TODO: Toss a warning saying the user already exists
    end

    redirect '/users-list?msg=Saved'
  end
end


if __FILE__ == $0
  Helpdesk.run!
end