require_relative '../app'
require 'rack/test'
require 'rspec'

#rspec spec\app_spec.rb --color --format documentation

ENV['RACK_ENV'] = 'test'

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
end
