class AddCalendarToTasks < ActiveRecord::Migration
  def change
  	add_column :tasks, :calendar_id, :integer
  	add_index :tasks, :calendar_id
  end
end
