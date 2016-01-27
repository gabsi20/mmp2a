class MakeUserCalendarPairsUnique < ActiveRecord::Migration
  def change
  	add_index :calendars_users, [:calendar_id, :user_id], :unique => true
  end
end
