class Task < ActiveRecord::Base
	has_many :statuses
	has_many :users, through: :statuses
end
