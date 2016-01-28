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

  def self.unsync selected, user
    exist = user.calendars
    exist.each{ |calendar|
      if selected.nil?
        user.calendars.clear
        Status.where(:user_id => current_user).destroy_all
      elsif self.calendar_is_deselected selected, calendar
        calendar.users.delete(user)
        Status.delete_all_statuses calendar, user
      end
    }
  end

  def self.calendar_is_deselected selected, calendar
    !selected.any? do |selectedmap|
      selectedmap[1] == calendar.uid
    end
  end
end
