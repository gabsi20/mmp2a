class SyncController < ApplicationController
	before_action :setup
	require 'google/api_client'

	def select
		calendar_result = @client.execute( 
				:api_method => @service.calendar_list.get,
				:parameters => {
					'calendarId' => ''
				}
    )
    
    @calendars = calendar_result.data.items
	end

	def calendars
		params['selection'].each{ |cid|
			calendar_result = @client.execute( 
					:api_method => @service.calendar_list.get,
					:parameters => {
						'calendarId' => cid[1]
					}
	    )

	    puts "RESULT: #{calendar_result.data}"
	    
	    if(Calendar.where("uid" => calendar_result.data["id"]).empty?)
	    	@thisCalendar = Calendar.create calendar_result.data
	    	tasks calendar_result.data["id"]
	    else
	    	thatCal = Calendar.where("uid" => calendar_result.data["id"]).first
	    	thatTasks = Task.where(:calendar_id => thatCal.id)
	    	thatTasks.each{ |task|
	    		if(Status.where(:task_id => task[:id], :user_id => current_user.id).empty?)
		    		Status.create current_user, task
		    	end
	    	}
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

	 events = task_result.data.items
		puts "menge #{events.count}"
	  events.each do |e|
	  	if e.status != "cancelled"
			  if e.start.date.present?
		  	  if e.start.date > Time.now
		        thisTask = Task.create e, @thisCalendar
		        Status.create current_user, thisTask
		      end
	      elsif
	      	if e.start.dateTime > Time.now
	      		thisTask = Task.create e, @thisCalendar
	      		Status.create current_user, thisTask
	      	end
	      end
	    end
	  end
	end

	def setup
		@client = Google::APIClient.new(:application_name => "ToDoify")
		token = Token.where(:user => current_user, :provider => "google_oauth2").first
  	@client.authorization.access_token = token.fresh_token
  	@service = @client.discovered_api('calendar', 'v3') 
	end

end
