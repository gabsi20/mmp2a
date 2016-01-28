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

    if !params['selection'].nil?
      params['selection'].each{ |cid|
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
          tasks calendar_result.data['id'], calendar
        else
          User.link_to_calendar calendar, current_user
          tasks = Task.where(:calendar_id => calendar.id)
          Status.create_status_for_user tasks, current_user
        end
      }
    end

    redirect_to tasks_path
  end

  def tasks uid, calendar
    task_result = @client.execute(
      :api_method => @service.events.list,
      :parameters => {
        'calendarId' => uid
      }
    )

   events = task_result.data.items
    events.each do |event|
      Task.save_event_in_database event, calendar, current_user
    end
  end

  def sync
    current_user.calendars.each{ |calendar|
      calendar_result = @client.execute(
        :api_method => @service.events.list,
        :parameters => {
          'calendarId' => calendar.uid
        }
      )
      events = calendar_result.data.items
      event_ids = events.map{ |event| event.id }
      Task.all.each{ |task|
        if !(event_ids.any?{ |id| task.uid == id})
          Task.delete_task_and_statuses task
        end
      }
      events.each{ |event|
        if !(Task.exists? :uid => event.id)
          if event.status != 'cancelled'
            if event.start.date.present?
              if event.start.date > Time.now.getlocal
                task = Task.create event, calendar
                calendar.users.each{ |user|
                  Status.create user, task
                }
              end
            elsif event.start.dateTime > Time.now.getlocal
              task = Task.create event, calendar
              calendar.users.each{ |user|
                Status.create user, task
              }
            end
          end
        end
      }
    }

    redirect_to tasks_path
  end

  def setup
    @client = Google::APIClient.new(:application_name => 'ToDoify')
    token = Token.where(:user => current_user, :provider => 'google_oauth2').first
    @client.authorization.access_token = token.fresh_token
    @service = @client.discovered_api('calendar', 'v3')
  end
end
