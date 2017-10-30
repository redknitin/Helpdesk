require 'sinatra'
require 'mongo'
#require 'securerandom'
require 'erb'
require 'sinatra/base'
require 'digest/sha1'
require 'date'
require_relative 'app_config'
require_relative 'routes/init'
require_relative 'models/init'
require_relative 'helpers/init'

class Helpdesk < Sinatra::Base
  use Rack::Session::Pool #Dont "enable :sessions" because it adds Rack::Session::Cookie to the stack but we want Rack::Session::Pool instead
  set :root, File.dirname(__FILE__) #Needed when including route handlers in a subdirectory (Eg. ours are in /routes)
end

if __FILE__ == $0
  Helpdesk.run!
end
