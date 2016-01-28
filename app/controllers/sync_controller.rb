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

        if(Calendar.where("uid" => calendar_result.data["id"]).empty?)
          thisCalendar = Calendar.create calendar_result.data
          current_user.calendars << thisCalendar
          tasks calendar_result.data["id"], thisCalendar
        else
          thatCal = Calendar.where("uid" => calendar_result.data["id"]).first
          thatTasks = Task.where(:calendar_id => thatCal.id)
          thatTasks.each{ |task|
            if(Status.where(:task_id => task[:id], :user_id => current_user.id).empty?)
              Status.create current_user, task
            end
          }
          current_user.calendars << thatCal
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
      puts events
      event_ids = events.map{ |event| event.id }
      Task.all.each{ |t|
        if !(event_ids.any?{ |id| t.uid == id})
          delete_task t
        end
      }
      events.each{ |e|
        if Task.where(:uid => e.id).empty?
          if e.status != "cancelled"
            if e.start.date.present?
              if e.start.date > Time.now
                thisTask = Task.create e, calendar
                calendar.users.each{ |user|
                  Status.create user, thisTask
                }
              end
            elsif e.start.dateTime > Time.now
              thisTask = Task.create e, calendar
              calendar.users.each{ |user|
                Status.create user, thisTask
              }
            end
          end
        end
      }
    }

    redirect_to tasks_path
  end

  def delete_task t
    t.statuses.each{ |status|
      status.destroy
    }
    t.destroy
  end

  def setup
    @client = Google::APIClient.new(:application_name => "ToDoify")
    token = Token.where(:user => current_user, :provider => "google_oauth2").first
    @client.authorization.access_token = token.fresh_token
    @service = @client.discovered_api('calendar', 'v3')
  end
end
