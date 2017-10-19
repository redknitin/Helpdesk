require 'securerandom'

class Helpdesk < Sinatra::Base
  #List all uoms
  get '/contact-list' do
    self.init_ctx
    #check if role is admin
    if !self.is_user_logged_in() || !(['admin', 'helpdesk'].include? @rolename)
      redirect '/'
      return #Does execution stop with a redirect, or do we need a return in this framework?
    end

    @skip = 0
    if @skip != nil && @skip != ''
      @skip = @params[:skip].to_i
    end

    @criteria = {}
    if (@params[:name] != nil && @params[:name] != '') then @criteria[:name] = {  '$regex' => '.*' + Regexp.escape(@params[:name]) + '.*', '$options' => 'i' } end
    if (@params[:phone] != nil && @params[:phone] != '') then @criteria[:phone] = { '$regex' => '.*' + Regexp.escape(@params[:phone]) + '.*', '$options' => 'i' } end
    if (@params[:email] != nil && @params[:email] != '') then @criteria[:email] = { '$regex' => '.*' + Regexp.escape(@params[:email]) + '.*', '$options' => 'i' } end

    @totalrowcount = 0
    @totalrowcount = @list = @db[:contacts].count()
    @list = @db[:contacts].find(@criteria).skip(@skip).limit(@pagesize)

    @showpager = true

    erb :contactslist
  end

  #Create a user account
  post '/contact-save' do
    self.init_ctx
    #check if role is admin before saving
    if !self.is_user_logged_in() || (!['admin', 'helpdesk'].include? @rolename)
      redirect '/'
      return #Does execution stop with a redirect, or do we need a return in this framework?
    end

    if @params[:code] != nil && @params[:code].downcase == 'new'
      redirect '/contact-list?msg=Cannot use NEW as UOM code'
      return
    end

    cnt = (@params[:code] == nil || @params[:code] == '') ? 0 : @db[:contacts].find('code' => @params[:code]).count()
    if cnt == 0
      @params[:code] = SecureRandom.uuid
      reccontact = {
          :code => @params[:code],
          :name => @params[:name],
          :phone => @params[:phone],
          :email => @params[:email]
      }

      @db[:contacts].insert_one reccontact
    elsif cnt == 1
      reccontact = @db[:personnel].find('code' => @params[:code]).limit(1).first
      reccontact[:name] = @params[:name]
      reccontact[:phone] = @params[:phone]
      reccontact[:email] = @params[:email]

      @db[:contacts].update_one(
          {'code' => @params[:code]},
          reccontact,
          {:upsert => false}
      )
    else
      #TODO: Toss a warning
    end

    @db.close
    redirect '/contact-list?msg=Saved'
  end

  #Get info about a single user
  get '/contact-detail/:code' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if !['admin', 'helpdesk'].include? @rolename
      redirect '/'
      return
    end

    @rec = @db[:contacts].find('code' => @params[:code]).limit(1).first

    erb :contactdetail
  end

end