class Helpdesk < Sinatra::Base
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

    @criteria = {}
    if (@params[:username] != nil && @params[:username] != '') then @criteria[:username] = {  '$regex' => '.*' + Regexp.escape(@params[:username]) + '.*', '$options' => 'i' } end
    if (@params[:rolename] != nil && @params[:rolename] != '') then @criteria[:rolename] = {  '$regex' => '.*' + Regexp.escape(@params[:rolename]) + '.*', '$options' => 'i' } end
    if (@params[:email] != nil && @params[:email] != '') then @criteria[:email] = {  '$regex' => '.*' + Regexp.escape(@params[:email]) + '.*', '$options' => 'i' } end
    if (@params[:display] != nil && @params[:display] != '') then @criteria[:display] = {  '$regex' => '.*' + Regexp.escape(@params[:display]) + '.*', '$options' => 'i' } end
    if (@params[:phone] != nil && @params[:phone] != '') then @criteria[:phone] = {  '$regex' => '.*' + Regexp.escape(@params[:phone]) + '.*', '$options' => 'i' } end

    @totalrowcount = 0
    @totalrowcount = @list = @db[:users].find(@criteria).count()
    @list = @db[:users].find(@criteria).skip(@skip).limit(@pagesize)

    @showpager = true

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

    cnt = @db[:users].find('username' => @params[:id]).count()
    if cnt == 0 && @params[:opmode] == 'new'
      cntemail = @db[:users].find('email' => @params[:email]).count()
      if cntemail > 0 #!= nil
        redirect '/users-list?msg=Email+already+exists'
        return
      end

      recuser = {
          :username => @params[:id],
          :password => Digest::SHA1.hexdigest(@params[:pw]),
          :rolename => @params[:rolename],
          :email => @params[:email],
          :phone => @params[:phone],
          :display => @params[:display],
          :ticket_details => @params[:ticket_details] == 'on' ? true : false,
          :islocked => 'false'
      }

      @db[:users].insert_one recuser
    elsif cnt == 1 && @params[:opmode] == 'update'
      recuser = @db[:users].find('username' => @params[:id]).limit(1).first

      if recuser[:email] != @params[:email]
        cntemail = @db[:users].find('email' => @params[:email]).count()
        if cntemail > 0 #!= nil
          redirect "/user-detail/#{@params[:id]}?msg=Email+already+exists"
          return
        end
      end

      recuser[:rolename] = @params[:rolename]
      recuser[:email] = @params[:email]
      recuser[:phone] = @params[:phone]
      recuser[:display] = @params[:display]
      recuser[:ticket_details] = @params[:ticket_details] == 'on' ? true : false
      #recuser[:islocked] = 'false'

      recuser[:islocked] = @params[:islocked] == 'on' ? 'true' : 'false'

      if @params[:pw] != nil && @params[:pw] != ''
        recuser[:password] = Digest::SHA1.hexdigest(@params[:pw])
      end

      @db[:users].update_one(
          {'username' => @params[:id]},
          recuser,
          {:upsert => false}
      )
    else
      #TODO: Toss a warning
    end

    session[:ticket_details] = @params[:ticket_details] == 'on' ? true : false

    @db.close
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

  #Get info about a single user
  get '/userprofile' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    @rec = @db[:users].find('username' => @username).limit(1).first

    erb :userprofile
  end

  post '/userprofile' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    @rec = @db[:users].find('username' => @username).limit(1).first

    reccnt = @db[:users].find('email' => @params[:email], 'username' => {'$ne' => @username}).count #limit(1).first issue post #36 Message displayed "Email+already+exists", but only current record has this email.
    if reccnt > 0 #!= nil
      redirect '/userprofile?msg=Email+already+exists'
      return
    end

    fields = ['display', 'phone', 'email']

    fields.each do |x|
      @rec[x] = @params[x]
    end

    @rec[:ticket_details] = @params[:ticket_details] == 'on' ? true : false

    @db[:users].update_one(
        {'username' => @username},
        @rec,
        {:upsert => false}
    )

    session[:ticket_details] = @rec[:ticket_details]

    redirect '/userprofile?msg=Saved'
  end

  get '/register-user' do
    self.init_ctx
    erb :registeruser
  end

  post '/register-user' do
    self.init_ctx

    if @params[:pw] != @params[:confirmpw]
      redirect '/register-user?msg=Password+and+confirmation+do+not+match'
      return
    end

    reccnt = @db[:users].find('username' => @username).count #limit(1).first
    if reccnt > 0 #!= nil
      redirect '/register-user?msg=Username+already+exists'
      return
    end

    reccnt = @db[:users].find('email' => @params[:email]).count #limit(1).first
    if reccnt > 0 #!= nil
      redirect '/register-user?msg=Email+already+exists'
      return
    end

    recuser = {
        :username => @params[:id],
        :password => Digest::SHA1.hexdigest(@params[:pw]),
        :rolename => 'requester',
        :email => @params[:email],
        :phone => @params[:phone],
        :display => @params[:display],
        :ticket_details => @params[:ticket_details] == 'on' ? true : false,
        :islocked => 'false'
    }

    @db[:users].insert_one recuser
    
    redirect '/login'
  end
end