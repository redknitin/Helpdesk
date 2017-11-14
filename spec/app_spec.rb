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

	it 'shows login' do
		get '/login'
		expect(last_response.status).to eq 200
		expect(last_response.body).to include('Login')
	end

	it 'actually logs in' do
		post '/login', { :id => 'admin', :pw => 'admin' }
		expect(last_response.status).to eq 302

		get '/tickets-list'
		expect(last_response.status).to eq 200
		expect(last_response.body).to include('Click on the request ID to view details of the event')
	end

	it 'stops unauthorized users' do
		post '/login', { :id => 'admin', :pw => 'notadmin' }
		expect(last_response.status).to eq 302

		get '/tickets-list'
		expect(last_response).to be_redirect
		# expect(last_response.status).to eq 302
		
		expect(last_response.location).to include('/login')

		# follow_redirect!
		# expect(last_request.url).to include('/login')
		# puts last_response.body
		# expect(last_response.body).to include('Login')
	end

	it 'registers new users' do
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
end
