class Helpdesk < Sinatra::Base
  #Home page of the application
  get '/' do
    self.init_ctx
    appsetup() #Check if the app needs first-time setup
    erb :index
  end
end