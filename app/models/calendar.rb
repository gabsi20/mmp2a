class Calendar < ActiveRecord::Base
	has_and_belongs_to_many :users

	def self.create cal
		create! do |calendar|
			calendar.uid = cal["id"]
			calendar.name = cal["summary"]
		end 
	end
end
