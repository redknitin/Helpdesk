class Helpdesk < Sinatra::Base
  #Creates an alphanumeric code for identifying the trouble ticket
  def generate_code()
    @params[:code] = Array.new(5){rand(36).to_s(36)}.join.downcase
    code_exist = @db[:requests].find('code' => @params[:code]).count()
    while code_exist > 0
      @params[:code] = Array.new(5){rand(36).to_s(36)}.join.downcase
      code_exist = @db[:requests].find('code' => @params[:code]).count()
    end
  end
end
