class SyncController < ApplicationController
	before_action :setup
	require 'google/api_client'

	def calendars
		@result = @client.execute( 
				:api_method => @service.calendar_list.get,
				:parameters => {
					'calendarId' => ''
				}
    )
    
    @result.data.items.each { |calendar|
    	if(Calendar.where("uid" => calendar["id"]).empty?)
	    	Calendar.create(calendar)
  	  end
    }
	end

	def tasks
		@result = @client.execute( 
				:api_method => @service.calendar_list.get,
				:parameters => {
					'calendarId' => ''
				}
    )
	end

	def setup
		@client = Google::APIClient.new(:application_name => "ToDoify")
  	@client.authorization.access_token = Token.where(:user => current_user, :provider => "google_oauth2").first.token
  	@service = @client.discovered_api('calendar', 'v3') 
	end

end
