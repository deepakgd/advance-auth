class User < ActiveRecord::Base
	def generate_user_token
		return SecureRandom.urlsafe_base64(90, false)+'_'+self.id.to_s
	end
end
