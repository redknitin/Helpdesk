class Helpdesk < Sinatra::Base
  def get_user_display_from_id(a_id)
    return (@db[:users].find('username' => a_id).limit(1).first)[:display]
  end
end