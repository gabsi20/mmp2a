class ChangeDateToDatetime < ActiveRecord::Migration
  def change
  	remove_column :tokens, :expires_at
  	add_column :tokens, :expires_at, :datetime
  end
end
