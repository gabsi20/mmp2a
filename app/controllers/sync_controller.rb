class SyncController < ApplicationController
	before_action :setup
	require 'google/api_client'

	def calendars
		calendar_result = @client.execute( 
				:api_method => @service.calendar_list.get,
				:parameters => {
					'calendarId' => ''
				}
    )
    
    calendar_result.data.items.each { |calendar|
    	if(Calendar.where("uid" => calendar["id"]).empty?)
	    	Calendar.create calendar
	    	tasks calendar["id"]
	    	puts "don't\n"
  	  end
    }
	end

	def tasks uid
		puts "do\n"
		task_result = @client.execute( 
				:api_method => @service.events.list,
				:parameters => {
					'calendarId' => uid
				}
    )

		while true
		  events = task_result.data.items
		  events.each do |e|
		    Task.create e
		  end
		  if !(page_token = task_result.data.next_page_token)
		    break
		  end
		  task_result = client.execute(:api_method => service.events.list,
		                          :parameters => {'calendarId' => 'primary',
		                                          'pageToken' => page_token})
		end
	end

	def setup
		@client = Google::APIClient.new(:application_name => "ToDoify")
  	@client.authorization.access_token = Token.where(:user => current_user, :provider => "google_oauth2").first.token
  	@service = @client.discovered_api('calendar', 'v3') 
	end

end
