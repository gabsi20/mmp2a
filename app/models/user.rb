class User < ActiveRecord::Base
	has_and_belongs_to_many :calendars

	def self.create_with_omniauth(auth)
	  create! do |user|
	    user.provider = auth['provider']
	    user.uid = auth['uid']
	    if auth['info']
	      user.firstname = auth['info']['first_name'] || ""
	      user.lastname = auth['info']['last_name'] || ""
	      user.email = auth['info']['email'] || ""
	    end
	  end
	end

end
