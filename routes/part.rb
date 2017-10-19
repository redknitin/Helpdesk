class Helpdesk < Sinatra::Base
  #List all parts
  get '/part-list' do
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
    @totalrowcount = @list = @db[:parts].count()
    @list = @db[:parts].find().skip(@skip).limit(@pagesize)

    @showpager = true

    erb :partlist
  end

  #Create a user account
  post '/part-save' do
    self.init_ctx
    #check if role is admin before saving
    if !self.is_user_logged_in() || @rolename != 'admin'
      redirect '/'
      return #Does execution stop with a redirect, or do we need a return in this framework?
    end

    if @params[:code] != 'nil' && @params[:code].downcase == 'new'
      redirect '/part-list?msg=Cannot use NEW as UOM code'
      return
    end
    @params[:code] = @params[:code].upcase

    cnt = @db[:parts].find('code' => @params[:code]).count()
    if cnt == 0
      recpart = {
          :code => @params[:code],
          :name => @params[:name],
          :description=> @params[:description]
      }

      @db[:parts].insert_one recpart
    elsif cnt == 1
      recpart = @db[:parts].find('code' => @params[:code]).limit(1).first
      recpart[:name] = @params[:name]
      recpart[:description] = @params[:description]

      @db[:parts].update_one(
          {'code' => @params[:code]},
          recpart,
          {:upsert => false}
      )
    else
      #TODO: Toss a warning
    end

    @db.close
    redirect '/part-list?msg=Saved'
  end

  #Get info about a single user
  get '/part-detail/:code' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename != 'admin'
      redirect '/'
      return
    end

    @rec = @db[:parts].find('code' => @params[:code]).limit(1).first
    recuoms = @db[:uoms].find()
    @uoms = []
    recuoms.each do |u|
      @uoms.push(u[:code])
    end
    @parttypes = ['Stock', 'Nonstock', 'Expense']

    erb :partdetail
  end

end