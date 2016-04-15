require "base64"
class UserController < ApplicationController
	# before_action :request_limit, except: [:advanceLogin]
  def login
  		if user = User.find_by(email: params[:email])
  			password = params[:password]
				encrypted_password = Digest::MD5.hexdigest("#{password}")
  			if encrypted_password == user.encrypted_password
  				render json: { message: "Login Success", user: user}
  			else
  				render json: { error: "Invalid password"}, status: 400
  			end
  		else
  			render json: {error: "Invalid User name"}, status: 400
  		end

  end

 def create
		user = User.new
		user.first_name = params[:first_name]
		user.last_name = params[:last_name]
		user.email = params[:email]
		password = params[:password]
		user.encrypted_password = Digest::MD5.hexdigest("#{password}")
		# binding.pry
			if user.save
				user.authToken = user.generate_user_token
				user.save
				render json: { user: user }
			else
				render json: { error: "Unable to create user try again"}, status: 400
			end
	end

	def index
		user = User.all
		render :json => user
	end


	def detail
		user = User.find(params[:id])
		render :json => user;
	end

	def edit
		user = User.find(params[:id])
		render json: user
	end

	def update
		user = User.find(params[:id])
		user.first_name = params[:first_name]
		user.last_name = params[:last_name]
		user.email = params[:email]
		if user.save
			user.save
			render json:  user
		else
			render json: {error: "Unable to update user details. Try again"}, status: 400
		end
	end

	def delete
		user = User.find(params[:id])
		if user.destroy
			render json: {message: "Successfully deleted"}, status: 200
		else
			render json: {message: "Unable to delete user. Try again"}, status: 400
		end
	end


	def advanceLogin
  		if user = User.find_by(email: params[:email])
  			password =  Base64.decode64(params[:password])
				encrypted_password = Digest::MD5.hexdigest("#{password}")
				# binding.pry
  			if encrypted_password == user.encrypted_password
  				render json: { message: "Login Success", token: user.generate_user_token, refresh_token: "casdf234dfasser234dssaf24324@!@#$%^sdfasdf", request_limit:100,time_expiry:60000}
  			else
  				render json: { error: "Invalid password"}, status: 400
  			end
  		else
  			render json: {error: "Invalid User name"}, status: 400
  		end

  end
end
