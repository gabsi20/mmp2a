class CreateApitokens < ActiveRecord::Migration
  def change
    create_table :apitokens do |t|
    	t.string :token
    	t.references :user

      t.timestamps null: false
    end
  end
end
