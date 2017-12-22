class Helpdesk < Sinatra::Base
  def get_part_display_from_id(code)
    name_code = (@db[:parts].find('code' => code).limit(1).first)
    return name_code[:code] + ' - ' +name_code[:name]
  end
end