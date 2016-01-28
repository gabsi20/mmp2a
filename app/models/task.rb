# Task Objects contains information from
# Google Calendar Events
class Task < ActiveRecord::Base
  belongs_to :calendars, :class_name => Task, :foreign_key => 'calendar_id'
  has_many :statuses
  has_many :users, through: :statuses

  def self.create taskinfo, calendar
    create! do |task|
      task.uid = taskinfo.id || ''
      task.title = taskinfo.summary || ''
      task.description = taskinfo.description || ''
      if taskinfo.creator.present?
        if taskinfo.creator.displayName.present?
          task.autor = taskinfo.creator.displayName || ''
        end
      end
      if taskinfo.start.date.present?
        task.due = taskinfo.start.date || ''
      else
        task.due = taskinfo.start.dateTime || ''
      end
      participants = []
      taskinfo.attendees.each do |attendee|
        participants.push attendee['displayName']
      end
      task.participants = participants.join(', ') || ''
      task.calendar_id = calendar.id
    end
  end

  def self.save_event_in_database event, calendar
    if event.status != 'cancelled'
      if event.start.date.present?
        if event.start.date > Time.now.getlocal
          task = Task.create event, calendar
          calendar.users.each do |user|
            Status.create user, task
          end
        end
      elsif event.start.dateTime > Time.now.getlocal
        task = Task.create event, calendar
        calendar.users.each do |user|
          Status.create user, task
        end
      end
    end
  end

  def self.delete_task_and_statuses task
    task.statuses.each do |status|
      status.destroy
    end
    task.destroy
  end
end
