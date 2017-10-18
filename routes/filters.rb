class Helpdesk < Sinatra::Base
  # before do #Why doesn't my regex work up here /^(?!\/(login|logout)
  #   allowed_anony = ['/login', '/', '/submit-request', '/usecode']
  #   pass if allowed_anony.include? request.path_info
  #   if session[:username] == nil || session[:username] == ''
  #     if request.request_method.downcase == 'get'
  #       session[:returnurl] = request.path_info
  #     else
  #       session[:returnurl] = nil
  #     end
  #     redirect '/login'
  #   end
  # end
end