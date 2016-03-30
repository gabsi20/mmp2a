class ApitokenController < ApplicationController
	def index
		if !current_user.apitoken
			Apitoken.create current_user
		end
		@token = current_user.apitoken
	end
end
