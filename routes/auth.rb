class Helpdesk < Sinatra::Base
  #Process login inputs
  post '/login' do
    self.init_ctx

    usr = @db[:users].find(
        'username' => @params[:id],
        'password' => Digest::SHA1.hexdigest(@params[:pw]),
        'islocked' => 'false'
    ).limit(1).first

    if usr == nil
      redirect '/login?msg=Invalid+login'
      return #redirect is supposed to stop execution of this method, but just to be sure
    end

    session[:rolename] = usr[:rolename]
    session[:username] = usr[:username]
    redirect '/'
  end

  #Logout the user by clearing session information
  get '/logout' do
    #self.init_ctx
    session[:username] = session[:rolename] = nil
    @username = @rolename = nil
    redirect '/'
  end

  #Displays the login page
  get '/login' do
    self.init_ctx
    #if @params[:msg] != nil && @params[:msg] != ''
    #  @msg = @params[:msg]
    #end
    erb :login
  end

  #Displays the forgot password page
  get '/forgot-password' do
    self.init_ctx
    #if @params[:msg] != nil && @params[:msg] != ''
    #  @msg = @params[:msg]
    #end
    erb :forgotpass
  end

  post '/forgot-password' do
    self.init_ctx

    usr = @db[:users].find(
        'email' => @params[:email],
    ).limit(1).first
    #TODO: There could be multiple user accounts with the same email address; we have to stop this from happening

    if usr == nil
      redirect '/login?msg=Invalid+login'
      return #redirect is supposed to stop execution of this method, but just to be sure
    end

    #TODO: Ideally, we should send the user a link by email to confirm the password reset

    usr[:password] = Digest::SHA1.hexdigest('password')
    #TODO: When we have email working, set the password to a random string and send by email

    @db[:users].update_one(
        {'username' => usr[:username]},
        usr,
        {:upsert => false}
    )

    #TODO: Display a message conveying that the password has been reset
    redirect '/login?msg=Password+has+been+reset'
  end
end