class Helpdesk < Sinatra::Base
  #Display the new trouble ticket form
  get '/help-me' do
    self.init_ctx
    if self.is_user_logged_in && @rolename == 'requester'
      rec = @db[:users].find('username' => @username).limit(1).first
      if rec != nil
        @phone = rec[:phone]
        @email = rec[:email]
        @display = rec[:display]
      end
    else
      @phone = @params[:phone] unless (@params[:phone] == nil || @params[:phone] == '')
      @email = @params[:email] unless (@params[:email] == nil || @params[:email] == '')
      @display = @params[:display] unless (@params[:display] == nil || @params[:display] == '')
    end
    erb :helpme
  end

  #Creates the new trouble ticket
  post '/help-me' do
    self.init_ctx
    self.generate_code

    @params[:status] = @statuses[0] # 'New'
    @params[:updatedat] = @params[:createdat] = Time.now.strftime(@datetimefmt)
    if @username != nil && @username != ''
      @params[:createdby] = @params[:updatedby] = @username
    end
    @params[:myguid] = SecureRandom.uuid
    @db[:requests].insert_one @params
    @db.close
    redirect '/'
  end


  #List all trouble tickets
  get '/tickets-list' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    @skip = 0
    if @skip != nil && @skip != ''
      @skip = @params[:skip].to_i
    end

    @criteria = {}
    if (@params[:code] != nil && @params[:code] != '') then @criteria[:code] = {  '$regex' => '.*' + Regexp.escape(@params[:code]) + '.*', '$options' => 'i' } end
    if (@params[:complaint] != nil && @params[:complaint] != '') then @criteria[:complaint] = { '$regex' => '.*' + Regexp.escape(@params[:complaint]) + '.*', '$options' => 'i' } end
    if (@params[:status] != nil && @params[:status] != '') then @criteria[:status] = {  '$regex' => '.*' + Regexp.escape(@params[:status]) + '.*', '$options' => 'i' } end

    @totalrowcount = 0
    if @rolename == 'requester'
      @criteria[:createdby] = @username
      #Helpdesk agents and admins can view the statuses of all requests
    end
    @totalrowcount = @list = @db[:requests].find(@criteria).count()
    @list = @db[:requests].find(@criteria, :sort => {'updatedat': -1}).skip(@skip).limit(@pagesize)

    @showpager = true

    erb :ticketslist
  end

  #Change the ticket status
  post '/ticket-status' do
    self.init_ctx

    @record = @db[:requests].find('code' => @params[:code]).limit(1).first;

    @record[:updatedat] = Time.now.strftime(@datetimefmt)
    @record[:updatedby] = @username
    @record[:status] = @params[:status]

    @db[:requests].update_one(
        {'code' => params[:code]},
        @record,
        {:upsert => false}
    )

    @db.close

    redirect '/tickets-list'
  end

  #Get info about a single trouble ticket
  get '/ticket-detail/:code' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:code]).limit(1).first
      @personnel = []
    else
      @rec = @db[:requests].find('code' => @params[:code]).limit(1).first
      @personnel = @db[:personnel].find()
    end

    @parts = @db[:parts].find()

    erb :ticketdetail
  end

  #Get info about a single trouble ticket
  post '/ticket-detail/:code' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:code]).limit(1).first
      # @personnel = []
    else
      @rec = @db[:requests].find('code' => @params[:code]).limit(1).first
      # @personnel = @db[:personnel].find()
    end

    if @rec == nil
      redirect '/tickets-list'
      return
    end

    savedfields = ['name', 'phone', 'email', 'complaint', 'description', 'room', 'locationdescription', 'org', 'dept', 'building', 'floor', 'locorg', 'locsite', 'locbldg', 'locfloor', 'locroom']

    savedfields.each do |x|
      @rec[x] = @params[x]
    end


    @db[:requests].update_one(
        {'code' => params[:code]},
        @rec,
        {:upsert => false}
    )

    @db.close
    
    redirect ('/ticket-detail/' + @params[:code])
  end

  post '/comment-delete/:ticket' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:ticket]).limit(1).first
    else
      @rec = @db[:requests].find('code' => @params[:ticket]).limit(1).first
    end
    #TODO: Replace this drama queen of a code with a simple count check if we aren't using any of the record fields when posting
    if @rec == nil
      redirect '/'
      return #Is a return absolutely necessary?
    end

    @rec[:comments].delete(@rec[:comments].find { |x| x[:at] == @params[:at] && x[:by] == @params[:by] } )

    @db[:requests].update_one(
        {'code' => @params[:ticket]},
        @rec,
        {:upsert => false}
    )

    @db.close

    redirect '/ticket-detail/' + @params[:ticket] + '?msg=Comment+deleted'
  end

  post '/comment-add/:ticket' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:ticket]).limit(1).first
    else
      @rec = @db[:requests].find('code' => @params[:ticket]).limit(1).first
    end
    #TODO: Replace this drama queen of a code with a simple count check if we aren't using any of the record fields when posting
    if @rec == nil
      redirect '/'
      return #Is a return absolutely necessary?
    end

    @db[:requests].update_one(
        {'code' => params[:ticket]},
        {'$push' => {'comments' => {
            :txt => @params[:txt],
            :at => Time.now.strftime(@datetimefmt),
            :by => @username
        }}},
        {:upsert => false}
    )

    @db.close

    redirect '/ticket-detail/' + @params[:ticket]
  end

  post '/ticket-assign/:ticket' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if ['helpdesk', 'admin'].include? @rolename
      @rec = @db[:requests].find('code' => @params[:ticket]).limit(1).first
    else
      redirect '/login'
      return
    end

    #TODO: Replace this drama queen of a code with a simple count check if we aren't using any of the record fields when posting
    if @rec == nil
      redirect '/'
      return #Is a return absolutely necessary?
    end

    @rec['assigned'] = @params[:assigned]

    assigned_rec = @db[:requests].find('code' => @params[:ticket], 'assigned.assigned' => @params[:assigned]).limit(1).first
    if assigned_rec == nil
    @db[:requests].update_one(
        {'code' => params[:ticket]},
        {'$push' => {'assigned' => {
            :assigned => @params[:assigned],
            :at => Time.now.strftime(@datetimefmt),
            :by => @username
        }}},
        {:upsert => false}
    )
    else
      redirect '/ticket-detail/'+@params[:ticket]+'?msg='+@params[:assigned]+' is already assigned'
    end


    @db.close

    redirect '/ticket-detail/'+@params[:ticket]
  end

  post '/assign-delete/:ticket' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:ticket]).limit(1).first
    else
      @rec = @db[:requests].find('code' => @params[:ticket]).limit(1).first
    end
    #TODO: Replace this drama queen of a code with a simple count check if we aren't using any of the record fields when posting
    if @rec == nil
      redirect '/'
      return #Is a return absolutely necessary?
    end

    @rec[:assigned].delete(@rec[:assigned].find { |x| x[:assigned] == @params[:assigned_code]  } )

    @db[:requests].update_one(
        {'code' => @params[:ticket]},
        @rec,
        {:upsert => false}
    )

    @db.close

    redirect '/ticket-detail/' + @params[:ticket] + '?msg='+self.get_personnel_name_from_id(@params[:assigned_code])+'+deleted'
  end

  post '/ticket-part-remove/:ticket' do
    partid = @params['part']

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:ticket]).limit(1).first
    else
      @rec = @db[:requests].find('code' => @params[:ticket]).limit(1).first
    end
    #TODO: Replace this drama queen of a code with a simple count check if we aren't using any of the record fields when posting
    if @rec == nil
      redirect '/ticket-detail/'+@params[:ticket]
      #redirect '/'
      return #Is a return absolutely necessary?
    end

    @rec[:parts].delete(@rec[:parts].find { |x| x[:part] == partid } )

    @db[:requests].update_one(
        {'code' => @params[:ticket]},
        @rec,
        {:upsert => false}
    )

    redirect '/ticket-detail/' + @params[:ticket] + '?msg=Part+deleted'
  end

  post '/ticket-part/:ticket' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:ticket]).limit(1).first
    else
      @rec = @db[:requests].find('code' => @params[:ticket]).limit(1).first
    end
    #TODO: Replace this drama queen of a code with a simple count check if we aren't using any of the record fields when posting
    if @rec == nil
      redirect '/'
      return #Is a return absolutely necessary?
    end

    check_existing = @rec[:parts].find { |x| x[:part] == @params[:code] }
    if check_existing != nil
      #redirect '/'
      redirect '/ticket-detail/'+@params[:ticket]+'?msg=Part+already+exists'
      return #Is a return absolutely necessary?
    end

    part_for_ticket = { :part => @params[:code], :uom => @params[:uom], :qty => @params[:qty] }


    @db[:requests].update_one(
        {'code' => @params[:ticket]},
        {'$push' => {'parts' => part_for_ticket }},
        {:upsert => false}
    )

    @db.close

    redirect '/ticket-detail/'+@params[:ticket]+'?msg=Part+saved'
  end

  post '/ticket-attach-remove/:ticket' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:ticket]).limit(1).first
    else
      @rec = @db[:requests].find('code' => @params[:ticket]).limit(1).first
    end
    #TODO: Replace this drama queen of a code with a simple count check if we aren't using any of the record fields when posting
    if @rec == nil
      redirect '/'
      return #Is a return absolutely necessary?
    end

    fileattachment = @rec[:attachments].find { |x| x[:storedas] == @params[:storedas] }
    filepath = @uploaddir+'/'+fileattachment[:storedas]
    File.delete(filepath) if File.exist?(filepath)
    @rec[:attachments].delete( fileattachment )  

    redirect '/ticket-detail/'+@params[:ticket]+'?msg=File+removed'
  end

  post '/ticket-attach/:ticket' do
    self.init_ctx
    if !self.is_user_logged_in()
      redirect '/login'
      return
    end

    if @rolename == 'requester'
      @rec = @db[:requests].find('createdby' => @username, 'code' => @params[:ticket]).limit(1).first
    else
      @rec = @db[:requests].find('code' => @params[:ticket]).limit(1).first
    end
    #TODO: Replace this drama queen of a code with a simple count check if we aren't using any of the record fields when posting
    if @rec == nil
      redirect '/'
      return #Is a return absolutely necessary?
    end

    if @params[:file] == nil
      redirect '/ticket-detail/'+@params[:ticket] 
      return
    end

    #File extension check
    if @uploadfilter != []
      dotsplitfilename = (@params[:file][:filename]).split('.')
      if dotsplitfilename.count < 2
        redirect '/ticket-detail/'+@params[:ticket]+'?msg=Invalid+file+extension'
        return
      end
      if !@uploadfilter.include? ('.' + dotsplitfilename[dotsplitfilename.count-1].downcase)
        redirect '/ticket-detail/'+@params[:ticket]+'?msg=Invalid+file+extension'
        return
      end
    end

    #File size limit check
    if @params[:file][:tempfile].size > 2000000
      redirect '/ticket-detail/'+@params[:ticket]+'?msg=File: '+@params[:file][:filename]+' has exceeded the 2 MB file size limit.'
      return
    end

    Dir.mkdir(@uploaddir) unless File.exists?(@uploaddir)
    storedas = SecureRandom.uuid
    require 'fileutils'    
    FileUtils.cp(@params[:file][:tempfile].path, @uploaddir+'/'+storedas)

    the_attachment = {
      :filename => @params[:file][:filename],
      :storedas => storedas,
      :at => Time.now.strftime(@datetimefmt),
      :by => @username
    }

    if @params[:filetag] != nil && @params[:filetag] != ''
      the_attachment[:tags] = [ @params[:filetag] ]
    end

    @db[:requests].update_one(
        {'code' => params[:ticket]},
        {'$push' => {'attachments' => the_attachment }},
        {:upsert => false}
    )

    @db.close

    redirect '/ticket-detail/'+@params[:ticket]+'?msg=File+saved'
  end

end
