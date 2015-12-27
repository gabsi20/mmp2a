class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.references :task, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :status

      t.timestamps null: false
    end
  end
end
