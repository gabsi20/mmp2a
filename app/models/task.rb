# Task Objects contains information from
# Google Calendar Events
class Task < ActiveRecord::Base
  belongs_to :calendar
  has_many :statuses
  has_many :users, through: :statuses

  def self.create taskinfo, calendar
    create! do |task|
      task.uid = taskinfo.id || ''
      task.title = taskinfo.summary || ''
      task.description = taskinfo.description || ''
      if taskinfo.creator.present?
        if taskinfo.creator.has_key? displayName
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

  def self.remove_deleted_events events
    event_ids = get_event_ids events
    Task.all.each do |task|
      if task_was_removed_from_google event_ids, task
        Task.delete_task_and_statuses task
      end
    end
  end

  def self.save_events_in_database events, tasks, calendar
    events.each do |event|
      if event_is_not_in_database tasks, event.id
        save_event_in_database event, calendar
      end
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

  def self.event_is_not_in_database tasks, event_id
    !tasks.any? do |task|
      task.uid == event_id
    end
  end

  def self.task_was_removed_from_google event_ids, task
    !event_ids.any?{ |id| task.uid == id}
  end

  def self.get_event_ids events
    events.map do |event|
      event.id
    end
  end
end
