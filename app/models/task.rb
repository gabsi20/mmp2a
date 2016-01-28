# Task Objects contains information from
# Google Calendar Events
class Task < ActiveRecord::Base
  belongs_to :calendars, :class_name => Task, :foreign_key => "calendar_id"
  has_many :statuses
  has_many :users, through: :statuses

  def self.create taskinfo, calendar
    create! do |task|
      task.uid = taskinfo.id || ""
      task.title = taskinfo.summary || ""
      task.description = taskinfo.description || ""
      if taskinfo.creator.present?
        if taskinfo.creator.displayName.present?
          task.autor = taskinfo.creator.displayName || ""
        end
      end
      if taskinfo.start.date.present?
        task.due = taskinfo.start.date || ""
      else
        task.due = taskinfo.start.dateTime || ""
      end
      participants = Array.new
      taskinfo.attendees.each{ |attendee|
        participants.push attendee['displayName']
      }
      task.participants = participants.join(", ") || ""
      task.calendar_id = calendar.id
    end
  end
end
