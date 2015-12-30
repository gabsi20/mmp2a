class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :provider
      t.string :token
      t.string :refresh_token
      t.date :expires_at
      t.references :user, index: true, foreign_key: true
      t.string :uid

      t.timestamps null: false
    end
  end
end
