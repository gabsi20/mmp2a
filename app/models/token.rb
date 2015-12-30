class Token < ActiveRecord::Base
  belongs_to :user

  def self.from_omniauth auth, user
		Token.where(:provider => auth['provider'], :uid => auth['uid']).first || self.create_with_omniauth(auth, user)
	end

	def self.create_with_omniauth auth, user
		create! do |token|
      token.provider = auth['provider'] || ""
      token.token = auth['credentials']['token'] || ""
      token.refresh_token = auth['credentials']['refresh_token'] || ""
      token.expires_at = Time.at(auth['credentials']['expires_at']) || ""
      token.uid = auth['uid'] || ""
      token.user = user
	  end
	end
end
