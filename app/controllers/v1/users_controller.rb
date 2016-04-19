require "base64"
class V1::UsersController < ApplicationController
# $redis.set("session",[])
  	$session = $redis.get("session").present? ? JSON.parse($redis.get("session")) : []

	def login
		# binding.pry
		  if user = User.find_by(email: params[:email])
  			password =  Base64.decode64(params[:password])
				encrypted_password = Digest::MD5.hexdigest("#{password}")
  			if encrypted_password == user.encrypted_password
  				# http://stackoverflow.com/questions/6936203/add-minutes-to-time-object
  				current_time = Time.now
  				expiry_time = current_time + 60 
  				session = {};
  				session = {
  					"user_id": user.id,
  					"token": user.generate_user_token,
  					"refresh_token": user.authToken,
  					"request_limit": 100,
  					"request_count": 0,
						"time_expiry": expiry_time
  				}
  				$session.push(JSON.parse(session.to_json))
  				$redis.set 'session', $session.to_json
  				render json: { message: "Login Success"}, status: 200
  			else
  				render json: { error: "Invalid password"}, status: 400
  			end
  		else
  			render json: {error: "Invalid User name"}, status: 400
  		end

	end


	def login2
		# binding.pry
		  if user = User.find_by(email: params[:email])
  			password =  Base64.decode64(params[:password])
				encrypted_password = Digest::MD5.hexdigest("#{password}")
				# binding.pry
  			if encrypted_password == user.encrypted_password
  				session = Session.new
  				session.user_id = user.id
  				session.token = user.generate_user_token
  				session.refresh_token = user.authToken
  				session.request_limit = 100
  				session.request_count = 0
  				current_time = Time.now
  				expiry_time = current_time + 10 
  				# http://stackoverflow.com/questions/6936203/add-minutes-to-time-object
  				session.time_expiry = expiry_time
  				if session.save
  					render json: { message: "Login Success", token: session.token, refresh_token: session.refresh_token, request_limit:100,time_expiry:60000}
  				else
  					render json: { error: session.errors.full_messages} and return
  				end
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
				render json: { error: user.errors.full_messages }, status: 400
			end
	end

	def logout

	end

	def edit

	end

	def forgotPassword

	end

	def resetPassword

	end

	def changePassword

	end

	def index
		user = User.all
		render :json => user 
	end

	def redisData
		sessionData = JSON.parse($redis.get("session"))  
		if request.headers["AuthToken"].present?
			# t1 = Time.now
			# t2 = Time.at(t1.to_i)
			
			sessionData.each do |obj|
			  binding.pry
				if obj["token"] == request.headers["AuthToken"]
					puts "matched %%%%%%%%%%%%%%%%%%%"
					if obj["request_limit"] <= 0 
						render :json => { error: "Token expired", status: 403}, status:403 and return
					elsif obj["time_expiry"].to_time >= Time.now
						obj["request_limit"] = obj["request_limit"] - 1
						puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^#{obj["request_limit"]}^^^^^^^^^^"
					else
						render :json => { error: "Token expired", status: 403}, status:403 and return
					end
				end
			end
		else
			render :json => { error: "Missing Auth Token", status: 401}, status:401 and return
		end
		# start redis server by using redis-server
		user = User.all
		
		$redis.set 'user', user.to_json
		render :json => JSON.parse($redis.get("user"))


	end

	def updateExistingDataRedis
		# http://stackoverflow.com/questions/9832124/saving-a-hash-to-redis-on-a-rails-app
		user = JSON.parse($redis.get("user"))
		# binding.pry
			user.push({
			    "id": 4,
			    "first_name": "testing",
			    "last_name": "testing",
			    "email": "testing1@vakilsearch.com",
			    "encrypted_password": "76963bb508af00aaa14d87d11059e461",
			    "mobileNumber": "34432432432",
			    "authToken": "RJf57kBADbFK59fKiEaLjs3tJcgwA7L0f5-OLB7MQlMef_cJmnRQN3EfsoE_6_MGJQzZec2__TlivULyYqGnQ6cJu9UdNlza2FypKDp63iXSJznkJLVOzhwK_4",
			    "status": "3245346455",
			    "created_at": "2016-04-18T07:07:50.940Z",
			    "updated_at": "2016-04-18T07:07:51.044Z"
			  })
			render :json => user
	end



end