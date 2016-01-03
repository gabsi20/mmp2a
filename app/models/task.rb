class Task < ActiveRecord::Base
	has_many :statuses
	has_many :users, through: :statuses

	def self.create taskinfo
		create! do |task|
			task.title = taskinfo["summary"] || ""
			task.description = taskinfo["description"] || ""
			task.autor = taskinfo["creator"]["displayName"] || ""
			task.due = taskinfo["start"]["date"] || ""
			participants = Array.new
			taskinfo["attendees"].each{ |attendee|
				participants.push attendee["displayName"]
			}
			task.participants = participants.join(", ") || ""
		end 
	end
end
