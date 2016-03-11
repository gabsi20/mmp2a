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
      params['selection'].each do |calendar_id|
        calendar_result = @client.execute(
            :api_method => @service.calendar_list.get,
            :parameters => {
              'calendarId' => calendar_id[1]
            }
        )
        calendar = Calendar.where('uid' => calendar_result.data['id']).first
        if(calendar.blank?)
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
    events = get_events_from_google uid

    events.each do |event|
      Task.save_event_in_database event, calendar
    end
  end

  def sync
    current_user.calendars.each do |calendar|
      events = get_events_from_google calendar.uid
      tasks = Task.where(:calendar_id => calendar)

      #Task.remove_deleted_events events
      Task.save_events_in_database events, tasks, calendar
    end

    redirect_to tasks_path
  end

  def setup
    @client = Google::APIClient.new(:application_name => 'ToDoify')
    token = Token.where(:user => current_user,
                        :provider => 'google_oauth2').first
    @client.authorization.access_token = token.fresh_token
    @service = @client.discovered_api('calendar', 'v3')
  end

  def get_events_from_google calendar_id
    calendar_result = @client.execute(
      :api_method => @service.events.list,
      :parameters => {
        'calendarId' => calendar_id
      }
    )
    calendar_result.data.items
  end
end
