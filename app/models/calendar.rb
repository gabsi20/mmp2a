# Calendar Objects contains Google Calendar_id and its title
class Calendar < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :tasks

  def self.create cal
    create! do |calendar|
      calendar.uid = cal['id'] || ''
      calendar.name = cal['summary'] || ''
    end
  end

  def self.unsync selected, current_user
    exist = current_user.calendars
    exist.each{ |cal|
      if selected.nil?
        current_user.calendars.clear
        Status.where(:user_id => current_user).destroy_all
      # if calendar is selected don't delete it
      elsif !(selected.any?{ |selectedmap| selectedmap[1] == cal.uid})
        cal.users.delete(current_user)
        cal.tasks.each{ |mytask|
          unless Status.where(:user_id => current_user, :task_id => mytask).first.nil?
            Status.where(:user_id => current_user, :task_id => mytask).first.destroy
          end
        }
      end
    }
  end
end
