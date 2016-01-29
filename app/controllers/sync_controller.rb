# Handles Google database synchronization
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

    @exist = current_user.calendars
    @calendars = calendar_result.data.items
  end

  def calendars
    Calendar.unsync params['selection'], current_user

    unless params['selection'].nil?
      params['selection'].each do |cid|
        calendar_result = @client.execute(
            :api_method => @service.calendar_list.get,
            :parameters => {
              'calendarId' => cid[1]
            }
        )
        calendar = Calendar.where('uid' => calendar_result.data['id']).first
        if(calendar.nil?)
          calendar = Calendar.create calendar_result.data
          User.link_to_calendar calendar, current_user
          create_tasks calendar_result.data['id'], calendar
        else
          User.link_to_calendar calendar, current_user
          tasks = Task.where(:calendar_id => calendar.id)
          Status.create_status_for_user tasks, current_user
        end
      end
    end

    redirect_to tasks_path
  end

  def create_tasks uid, calendar
    task_result = get_events_from_google uid
    events = task_result.data.items

    events.each do |event|
      Task.save_event_in_database event, calendar
    end
  end

  def sync
    current_user.calendars.each do |calendar|
      calendar_result = get_events_from_google calendar.uid
      events = calendar_result.data.items
      event_ids = get_event_ids events
      tasks = Task.where(:calendar_id => calendar)

      Task.all.each do |task|
        if task_was_removed_from_google event_ids, task
          Task.delete_task_and_statuses task
        end
      end

      events.each do |event|
        if event_is_not_in_database tasks, event.id
          Task.save_event_in_database event, calendar
        end
      end
    end

    redirect_to tasks_path
  end

  def setup
    @client = Google::APIClient.new(:application_name => 'ToDoify')
    token = Token.where(:user => current_user, :provider => 'google_oauth2').first
    @client.authorization.access_token = token.fresh_token
    @service = @client.discovered_api('calendar', 'v3')
  end

  def task_was_removed_from_google event_ids, task
    !event_ids.any?{ |id| task.uid == id}
  end

  def get_events_from_google calendar_id
    @client.execute(
      :api_method => @service.events.list,
      :parameters => {
        'calendarId' => calendar_id
      }
    )
  end

  def event_is_not_in_database tasks, event_id
    !tasks.any? do |task|
      task.uid == event_id
    end
  end

  def get_event_ids events
    events.map do |event|
      event.id
    end
  end
end
