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
  	  end
    }

    redirect_to tasks_path
	end

	def tasks uid
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
		token = Token.where(:user => current_user, :provider => "google_oauth2").first
  	@client.authorization.access_token = token.fresh_token
  	@service = @client.discovered_api('calendar', 'v3') 
	end

end
