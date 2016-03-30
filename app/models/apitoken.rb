class Apitoken < ActiveRecord::Base
	belongs_to :user
	validates :token, uniqueness: true

	def self.create user
		create! do |apitoken|
			apitoken.user_id = user.id
			apitoken.token = rand(999)
		end
	end
end
