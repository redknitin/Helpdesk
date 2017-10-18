class Helpdesk < Sinatra::Base
  #List all uoms
  get '/uoms-list' do
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
    @totalrowcount = @list = @db[:uoms].count()
    @list = @db[:uoms].find().skip(@skip).limit(@pagesize)

    @showpager = true

    erb :uomslist
  end

  #Create a user account
  post '/uom-save' do
    self.init_ctx
    #check if role is admin before saving
    if !self.is_user_logged_in() || @rolename != 'admin'
      redirect '/'
      return #Does execution stop with a redirect, or do we need a return in this framework?
    end

    if @params[:code] != 'nil' && @params[:code].downcase == 'new'
      redirect '/uoms-list?msg=Cannot use NEW as UOM code'
      return
    end
    @params[:code] = @params[:code].upcase

    cnt = @db[:uoms].find('code' => @params[:code]).count()
    if cnt == 0
      recuom = {
          :code => @params[:code],
          :description => @params[:description],
          :type => @params[:type],
          :whole => (@params[:whole] == 'on' ? 'true' : 'false')
      }

      @db[:uoms].insert_one recuom
    elsif cnt == 1
      recuom = @db[:uoms].find('code' => @params[:code]).limit(1).first
      recuom[:description] = @params[:description]
      recuom[:type] = @params[:type]
      recuom[:whole] = (@params[:whole] == 'on' ? 'true' : 'false')

      @db[:uoms].update_one(
          {'code' => @params[:code]},
          recuom,
          {:upsert => false}
      )
    else
      #TODO: Toss a warning
    end

    @db.close
    redirect '/uoms-list?msg=Saved'
  end

  #Get info about a single user
  get '/uom-detail/:code' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename != 'admin'
      redirect '/'
      return
    end

    @uomtypes = ['Weight', 'Volume', 'Count']
    @rec = @db[:uoms].find('code' => @params[:code]).limit(1).first

    erb :uomdetail
  end

end