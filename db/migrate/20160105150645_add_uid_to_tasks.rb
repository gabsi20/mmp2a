class AddUidToTasks < ActiveRecord::Migration
  def change
  	add_column :tasks, :uid, :string
  end
end
