class User < ActiveRecord::Base
	has_and_belongs_to_many :calendars

	def self.create_with_omniauth auth
		create! do |user|
	    user.provider = auth['provider']
	    user.uid = auth['uid']
	    if auth['info']
	    	if auth['provider'] == "twitter"
	    		user.firstname = self.getfirstname auth || ""
	    		user.lastname = self.getlastname auth || ""
	    	else
		      user.firstname = auth['info']['first_name'] || ""
		      user.lastname = auth['info']['last_name'] || ""
		      user.email = auth['info']['email'] || ""
		    end
	    end
	  end
	end

	private
		def self.getfirstname auth
			if auth['info']['name'].split.count > 1
	      auth['info']['name'].split[0..-2].join(' ')
	    else
	      auth['info']['name']
	    end
	  end

	  def self.getlastname auth
	  	auth['info']['name'].split.last
	  end
end
