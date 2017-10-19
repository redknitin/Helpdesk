class Helpdesk < Sinatra::Base
  #List all uoms
  get '/store-list' do
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
    @totalrowcount = @list = @db[:stores].count()
    @list = @db[:stores].find().skip(@skip).limit(@pagesize)

    @showpager = true

    erb :storelist
  end

  #Create a user account
  post '/store-save' do
    self.init_ctx
    #check if role is admin before saving
    if !self.is_user_logged_in() || @rolename != 'admin'
      redirect '/'
      return #Does execution stop with a redirect, or do we need a return in this framework?
    end

    if @params[:code] != 'nil' && @params[:code].downcase == 'new'
      redirect '/store-list?msg=Cannot use NEW as UOM code'
      return
    end
    @params[:code] = @params[:code].upcase

    cnt = @db[:stores].find('code' => @params[:code]).count()
    if cnt == 0
      recstore = {
          :code => @params[:code],
          :name => @params[:name],
          :description=> @params[:description]
      }

      @db[:stores].insert_one recpersonnel
    elsif cnt == 1
      recstore = @db[:stores].find('code' => @params[:code]).limit(1).first
      recstore[:name] = @params[:name]
      recstore[:description] = @params[:description]

      @db[:stores].update_one(
          {'code' => @params[:code]},
          recstore,
          {:upsert => false}
      )
    else
      #TODO: Toss a warning
    end

    @db.close
    redirect '/store-list?msg=Saved'
  end

  #Get info about a single user
  get '/store-detail/:code' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename != 'admin'
      redirect '/'
      return
    end

    @rec = @db[:stores].find('code' => @params[:code]).limit(1).first

    erb :storedetail
  end

end