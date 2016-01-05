class CalendarsUsers < ActiveRecord::Migration
  def change
  	create_table :calendars_users, id: false do |t|
      t.integer :calendar_id
      t.integer :user_id

      t.timestamps null: false
    end

    add_index :calendars_users, :calendar_id
    add_index :calendars_users, :user_id
  end
end
