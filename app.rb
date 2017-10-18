require 'sinatra'
require 'mongo'
#require 'securerandom'
require 'erb'
require 'sinatra/base'
require 'digest/sha1'
require './app_config'

class Helpdesk < Sinatra::Base
  use Rack::Session::Pool #Dont "enable :sessions" because it adds Rack::Session::Cookie to the stack but we want Rack::Session::Pool instead

  #Initialize data needed for the application
  def initialize()
    super()
    @db = Mongo::Client.new((defined? AppConfig::DB_URL != nil) ? AppConfig::DB_URL : 'mongodb://127.0.0.1:27017/helpdesk')
    #@db = Mongo::Client.new(['127.0.0.1:27017'], :database => 'helpdesk') #The URL notation helps reduce this to a single config setting Eg. Mongo::Client.new('mongodb://127.0.0.1:27017/helpdesk')
    @datetimefmt = '%Y-%m-%d %H:%M:%S' #Add %z for timezone; make this a configuration option

    #Currently, anything that is hardcoded but needs to be moved into master data can be defined here as, for example, an array or dictionary
    @departments = (defined? AppConfig::MASTER_ORG_DEPT != nil) ? AppConfig::MASTER_ORG_DEPT : [
        {:org => 'Helpdesk Foundation', :dept => ['Software Development', 'Quality Control', 'Social Media Marketing', 'Training', 'Consulting', 'Administration', 'Human Resources', 'Procurement', 'Information Technology']},
        {:org => 'Mars Habitation Corporation', :dept => ['HVAC', 'MEP (Mechanical-Electrical-Plumbing)', 'QHSE (Quality-Health-Safety-Environment)', 'Cleaning', 'Security', 'Visitor Experience', 'Guest Relations', 'Procurement']}
    ]
    @statuses = (defined? AppConfig::MASTER_STATUSES != nil) ? AppConfig::MASTER_STATUSES : ['New', 'Assigned', 'Suspended', 'Completed', 'Cancelled']
    @roles = (defined? AppConfig::MASTER_ROLES != nil) ? AppConfig::MASTER_ROLES : ['requester', 'helpdesk', 'admin']

    @pagesize = (defined? AppConfig::UI_PAGE_SIZE != nil) ? AppConfig::UI_PAGE_SIZE : 10
  end

  # before do #Why doesn't my regex work up here /^(?!\/(login|logout)
  #   allowed_anony = ['/login', '/', '/submit-request', '/usecode']
  #   pass if allowed_anony.include? request.path_info
  #   if session[:username] == nil || session[:username] == ''
  #     if request.request_method.downcase == 'get'
  #       session[:returnurl] = request.path_info
  #     else
  #       session[:returnurl] = nil
  #     end
  #     redirect '/login'
  #   end
  # end

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

  post '/comment-add/:ticket' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:ticket]).limit(1).first
    else
      @rec = @db[:requests].find('code' => @params[:ticket]).limit(1).first
    end
    #TODO: Replace this drama queen of a code with a simple count check if we aren't using any of the record fields when posting
    if @rec == nil
      redirect '/'
      return #Is a return absolutely necessary?
    end

    @db[:requests].update_one(
        {'code' => params[:ticket]},
        {'$push' => {'comments' => {
            :txt => @params[:txt],
            :at => Time.now.strftime(@datetimefmt),
            :by => @username
        }}},
        {:upsert => false}
    )

    @db.close

    redirect '/ticket-detail/'+@params[:ticket]
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
  post '/user-save/:opmode' do
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
        :phone => @params[:phone],
        :display => @params[:display],
        :islocked => 'false'
    }

    cnt = @db[:users].find('username' => @params[:id]).count()
    if cnt == 0 && @params[:opmode] == 'new'
      @db[:users].insert_one recuser
      @db.close
    elsif cnt == 1 && @params[:opmode] == 'update'
      #TODO: Update the user
    else
      #TODO: Toss a warning
    end

    redirect '/users-list?msg=Saved'
  end

  #Get info about a single user
  get '/user-detail/:username' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename != 'admin'
      redirect '/'
      return
    end

    @rec = @db[:users].find('username' => @params[:username]).limit(1).first

    erb :userdetail
  end
end


if __FILE__ == $0
  Helpdesk.run!
end