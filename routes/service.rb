class Helpdesk < Sinatra::Base
  #List all parts
  get '/services-list' do
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
    if (@params[:code] != nil && @params[:code] != '') then @criteria[:code] = {  '$regex' => '.*' + Regexp.escape(@params[:code]) + '.*', '$options' => 'i' } end
    if (@params[:name] != nil && @params[:name] != '') then @criteria[:name] = {  '$regex' => '.*' + Regexp.escape(@params[:name]) + '.*', '$options' => 'i' } end
    if (@params[:description] != nil && @params[:description] != '') then @criteria[:description] = {  '$regex' => '.*' + Regexp.escape(@params[:description]) + '.*', '$options' => 'i' } end

    @totalrowcount = 0
    @totalrowcount = @list = @db[:services].find(@criteria).count()
    @list = @db[:services].find(@criteria).skip(@skip).limit(@pagesize)

    @showpager = true

    erb :serviceslist
  end

  #Create a user account
  post '/service-save' do
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

    cnt = @db[:services].find('code' => @params[:code]).count()
    if cnt == 0
      recservice = {
          :code => @params[:code],
          :name => @params[:name],
          :description=> @params[:description],
          :uom=> @params[:uom],
          :type=> @params[:type],
      }

      @db[:services].insert_one recservice
    elsif cnt == 1
      recservice = @db[:services].find('code' => @params[:code]).limit(1).first
      recservice[:name] = @params[:name]
      recservice[:description] = @params[:description]
      recservice[:uom] = @params[:uom]
      recservice[:type] = @params[:type]

      @db[:services].update_one(
          {'code' => @params[:code]},
          recservice,
          {:upsert => false}
      )
    else
      #TODO: Toss a warning
    end

    @db.close
    redirect '/services-list?msg=Saved'
  end

  #Get info about a single user
  get '/service-detail/:code' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename != 'admin'
      redirect '/'
      return
    end

    @rec = @db[:services].find('code' => @params[:code]).limit(1).first
    recuoms = @db[:uoms].find()
    @uoms = []
    recuoms.each do |u|
      @uoms.push(u[:code])
    end
    @servicetypes = ['Fixed Price', 'By Unit']

    erb :servicedetail
  end

end