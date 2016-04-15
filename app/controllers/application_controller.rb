class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  before_filter :request_count,:token_verify

  protected

	$request_count = 0;

  def request_count
  	$request_count = $request_count+1;
  	# if request.get?
  	#  binding.pry	
  	# end
  end
  def token_verify
  	# binding.pry
  	if request.headers['HTTP_TOKEN']
  		

  	end
  end
end
