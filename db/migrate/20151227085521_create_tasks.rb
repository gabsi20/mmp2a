class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.text :description
      t.string :autor
      t.string :participants
      t.datetime :due

      t.timestamps null: false
    end
  end
end
