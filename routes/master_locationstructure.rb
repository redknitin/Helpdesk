require 'json'

class Helpdesk < Sinatra::Base
	get '/dropdown/locorg' do		
		@locstruct.map { |x| { :label => x[:name], :value => x[:code] } }.to_json
	end

	get '/dropdown/locsite/:locorg' do
		sites = @locstruct.select { |x| x[:code] == @params[:locorg] }[0][:children]
		sites.map { |x| { :label => x[:name], :value => x[:code] } }.to_json
	end

	get '/dropdown/locbldg/:locorg/:locsite' do
		sites = @locstruct.select { |x| x[:code] == @params[:locorg] }[0][:children]
		bldgs = sites.select { |x| x[:code] == @params[:locsite] }[0][:children]
		bldgs.map { |x| { :label => x[:name], :value => x[:code] } }.to_json
	end

	get '/dropdown/locfloor/:locorg/:locsite/:locbldg' do
		sites = @locstruct.select { |x| x[:code] == @params[:locorg] }[0][:children]
		bldgs = sites.select { |x| x[:code] == @params[:locsite] }[0][:children]
		floors = bldgs.select { |x| x[:code] == @params[:locbldg] }[0][:children]
		floors.map { |x| { :label => x[:name], :value => x[:code] } }.to_json
	end

	get '/dropdown/locroom/:locorg/:locsite/:locbldg/:locfloor' do
		sites = @locstruct.select { |x| x[:code] == @params[:locorg] }[0][:children]
		bldgs = sites.select { |x| x[:code] == @params[:locsite] }[0][:children]
		floors = bldgs.select { |x| x[:code] == @params[:locbldg] }[0][:children]
		rooms = floors.select { |x| x[:code] == @params[:locfloor] }[0][:children]
		rooms.map { |x| { :label => x[:name], :value => x[:code] } }.to_json
	end
end
