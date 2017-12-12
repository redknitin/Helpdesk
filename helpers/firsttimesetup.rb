class Helpdesk < Sinatra::Base
  #Initializes the application for first-time use
  def appsetup()
    #If the database has no users, create the admin user with defaults
    if @db[:users].count == 0
      recuser = {
          :username => 'admin',
          :password => Digest::SHA1.hexdigest('admin'),
          :rolename => 'admin',
          :display => 'Administrator',
          :email => 'root@localhost',
          :islocked => 'false',
          :ticket_details => true
      }

      @db[:users].insert_one recuser
    end
  end
end