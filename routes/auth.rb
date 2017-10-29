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

    #Send the user a link by email to confirm the password reset
    usr[:reset_token] = Array.new(10){rand(36).to_s(36)}.join.downcase
    code_exist = @db[:users].find(:reset_token => usr[:reset_token]).count()
    while code_exist > 0
      usr[:reset_token] = Array.new(10){rand(36).to_s(36)}.join.downcase
      code_exist = @db[:users].find(:reset_token => usr[:reset_token]).count()
    end

    @db[:users].update_one(
        {'username' => usr[:username]},
        usr,
        {:upsert => false}
    )

    send_email({
      :recipient_name => usr[:display],
      :recipient_email => usr[:email],
      :subject => 'Password Reset',
      :body => "Your ID is: #{usr[:username]} and your password reset code is: #{usr[:reset_token]}"
      })

    #Display a message conveying that the password reset email has been sent
    redirect '/forgot-token?msg=Password+reset+email+has+been+sent'
  end

  get '/forgot-token' do
    self.init_ctx

    erb :forgottoken
  end

  post '/forgot-token' do
    self.init_ctx

    usr = @db[:users].find(
        'reset_token' => @params[:token],
    ).limit(1).first

    if usr == nil
      redirect '/forgot-token?msg=Invalid+token'
    end

    newpwd = Array.new(10){rand(36).to_s(36)}.join.downcase
    usr[:password] = Digest::SHA1.hexdigest(newpwd)

    send_email({
      :recipient_name => usr[:display],
      :recipient_email => usr[:email],
      :subject => 'New Password',
      :body => "Your ID is: #{usr[:username]} and your new password is: #{newpwd}"
      })

    usr.delete(:reset_token) #Strangely enough, this is .delete and not .delete!

    @db[:users].update_one(
        {'username' => usr[:username]},
        usr,
        {:upsert => false}
    )

    redirect '/login?msg=Password+has+been+reset'
  end

  get '/change-password' do
    self.init_ctx
    erb :changepassword
  end

  post '/change-password' do
    self.init_ctx
    if @username == nil || @username == ''
      redirect '/login'
    end

    if @params[:newpwd] != @params[:confirmpwd]
      redirect '/change-password?msg=Password+confirmation+invalid'
      return
    end

    usr = @db[:users].find(
        'username' => @username
    ).limit(1).first

    if Digest::SHA1.hexdigest(@params[:oldpwd]) != usr[:password]
      redirect '/change-password?msg=Old+password+invalid'
      return
    end

    usr[:password] = Digest::SHA1.hexdigest(@params[:newpwd])

    # send_email({
    #   :recipient_name => usr[:display],
    #   :recipient_email => usr[:email],
    #   :subject => 'New Password',
    #   :body => "Your ID is: #{usr[:username]} and your new password is: #{newpwd}"
    #   })

    @db[:users].update_one(
        {'username' => usr[:username]},
        usr,
        {:upsert => false}
    )

    redirect '/login?msg=Password+has+been+reset'
  end
end
