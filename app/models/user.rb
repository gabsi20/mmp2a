class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable
	has_and_belongs_to_many :calendars

	def self.from_omniauth auth
		self.where(:provider => auth['provider'], :uid => auth['uid']).first || self.create_with_omniauth(auth)
	end

	def self.create_with_omniauth auth
		create! do |user|
	    user.provider = auth['provider']
	    user.uid = auth['uid']
	    user.password = Devise.friendly_token[0,20]
	    if auth['info']
	      user.firstname = auth['info']['first_name'] || ""
	      user.lastname = auth['info']['last_name'] || ""
	      user.email = auth['info']['email'] || ""
	    end
	  end
	end
end
