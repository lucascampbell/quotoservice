require 'json'
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  
  private
  
  # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path
    end
    
    def internal_error_action
      render :json => {:text => "Internal Server Error"}.to_json, :status => 500
    end
    
    def not_found_action
      render :json => {:text => "Not Found."}.to_json, :status => 404
    end
end
