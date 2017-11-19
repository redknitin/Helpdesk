require 'json'

class Helpdesk < Sinatra::Base
	get '/dropdown/partuom/:partcode' do
	    @rec = @db[:parts].find('code' => @params[:partcode]).limit(1).first
		@uoms = []
		
	    recuoms = @db[:uoms].find()
	    recuoms.each do |x|
	    	if x[:code] == @rec[:uom]
	    		@uoms[0] = x #First UOM is the part code default
	    		break
	    	end
	    end

		#TODO: Add alternate UOMs

		@uoms.map { |iter| { :value => iter[:code], :label => iter[:description] } }.to_json
	end
end
