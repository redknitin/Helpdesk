require_relative '../app'
require 'rack/test'
require 'rspec'

#rspec spec\app_spec.rb --color --format documentation

ENV['RACK_ENV'] = 'test'
Mongo::Logger.logger.level = Logger::FATAL

describe 'Helpdesk' do
	include Rack::Test::Methods

	def app
		Helpdesk
	end

	#Check if the login page shows
	it 'shows login' do
    get '/' #App init is performed in here

		get '/login'
		expect(last_response.status).to eq 200
		expect(last_response.body).to include('Login')
	end

	#Perform a login with the default user account for admin
	it 'actually logs in' do
    get '/' #App init is performed in here

    post '/login', { :id => 'admin', :pw => 'admin' }
		expect(last_response.status).to eq 302

		get '/tickets-list'
		expect(last_response.status).to eq 200
		expect(last_response.body).to include('Click on the request ID to view details of the event')
	end

	#Ensure it doesn't accept an invalid password
	it 'stops unauthorized users' do
    get '/' #App init is performed in here

    post '/login', { :id => 'admin', :pw => 'notadmin' }
		expect(last_response.status).to eq 302

		get '/tickets-list'
		expect(last_response).to be_redirect
		expect(last_response.location).to include('/login')
	end

	#Register as a new user and perform a login
	it 'registers new users' do
    get '/' #App init is performed in here

    randomstr = Array.new(10){rand(36).to_s(36)}.join.downcase
		username = 'test_' + randomstr
		password = 'nitiniswritingthistest'

		post '/register-user', { :id => username, :pw => password, :confirmpw => password, :email => username + '@nospam.org', :phone => '+971501234567', :display => 'Test User ' + randomstr }
		expect(last_response).to be_redirect
		expect(last_response.location).to include('/login')

		post '/login', { :id => username, :pw => password }
		expect(last_response.status).to eq 302
		follow_redirect!
		expect(last_response.body).to include('View Request Status') #Only logged in users can view request status
  end

  #Gets location organizations
  it 'fetches location structure' do
    get '/dropdown/locorg'
    expect(last_response.status).to eq 200
    expect(last_response.body).to eq (AppConfig::MASTER_LOC_STRUCT.map { |x| { :label => x[:name], :value => x[:code] } }.to_json)
  end

  #TODO Run tests for other locations based on the config; if config is empty, test passes
end
