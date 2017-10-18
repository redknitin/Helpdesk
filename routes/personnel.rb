class Helpdesk < Sinatra::Base
  #List all uoms
  get '/personnel-list' do
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
    @totalrowcount = @list = @db[:personnel].count()
    @list = @db[:personnel].find().skip(@skip).limit(@pagesize)

    @showpager = true

    erb :personnellist
  end

  #Create a user account
  post '/personnel-save' do
    self.init_ctx
    #check if role is admin before saving
    if !self.is_user_logged_in() || @rolename != 'admin'
      redirect '/'
      return #Does execution stop with a redirect, or do we need a return in this framework?
    end

    if @params[:code] != 'nil' && @params[:code].downcase == 'new'
      redirect '/personnel-list?msg=Cannot use NEW as UOM code'
      return
    end
    @params[:code] = @params[:code].upcase

    cnt = @db[:personnel].find('code' => @params[:code]).count()
    if cnt == 0
      recpersonnel = {
          :code => @params[:code],
          :name => @params[:name],
          :type => @params[:type],
          :position=> @params[:position]
      }

      @db[:personnel].insert_one recpersonnel
    elsif cnt == 1
      recpersonnel = @db[:personnel].find('code' => @params[:code]).limit(1).first
      recpersonnel[:name] = @params[:name]
      recpersonnel[:type] = @params[:type]
      recpersonnel[:position] = @params[:position]

      @db[:personnel].update_one(
          {'code' => @params[:code]},
          recpersonnel,
          {:upsert => false}
      )
    else
      #TODO: Toss a warning
    end

    @db.close
    redirect '/personnel-list?msg=Saved'
  end

  #Get info about a single user
  get '/personnel-detail/:code' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename != 'admin'
      redirect '/'
      return
    end

    @personneltypes = ['Employee', 'Contractor', 'Volunteer', 'Client']
    @rec = @db[:personnel].find('code' => @params[:code]).limit(1).first

    erb :personneldetail
  end

end