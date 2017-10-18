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
end