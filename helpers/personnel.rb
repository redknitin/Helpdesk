class Helpdesk < Sinatra::Base
  def get_personnel_name_from_id(a_id)
    return (@db[:personnel].find('code' => a_id).limit(1).first)[:name]
  end
end