# Calendar Objects contains Google Calendar_id and its title
class Calendar < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :tasks

  def self.create cal
    create! do |calendar|
      calendar.uid = cal["id"] || ""
      calendar.name = cal["summary"] || ""
    end
  end
end
