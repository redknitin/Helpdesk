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

    @totalrowcount = 0
    @totalrowcount = @list = @db[:users].count()
    @list = @db[:users].find().skip(@skip).limit(@pagesize)

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
      recuser = {
          :username => @params[:id],
          :password => Digest::SHA1.hexdigest(@params[:pw]),
          :rolename => @params[:rolename],
          :email => @params[:email],
          :phone => @params[:phone],
          :display => @params[:display],
          :islocked => 'false'
      }

      @db[:users].insert_one recuser
    elsif cnt == 1 && @params[:opmode] == 'update'
      recuser = @db[:users].find('username' => @params[:id]).limit(1).first
      recuser[:rolename] = @params[:rolename]
      recuser[:email] = @params[:email]
      recuser[:phone] = @params[:phone]
      recuser[:display] = @params[:display]
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

    fields = ['display', 'phone', 'email']

    fields.each do |x|
      @rec[x] = @params[x]
    end

    @db[:users].update_one(
        {'username' => @username},
        @rec,
        {:upsert => false}
    )

    redirect '/userprofile?msg=Saved'
  end
end