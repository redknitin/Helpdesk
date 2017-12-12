class Helpdesk < Sinatra::Base
  #Checks if the username session value has been set
  def is_user_logged_in
    return session[:username] != nil && session[:username] != ''
  end

  #Initializes members variables based on session values, parameters, and other context data
  def init_ctx
    @username = session[:username]
    @rolename = session[:rolename]
    @ticket_details = session[:ticket_details]
  end
end