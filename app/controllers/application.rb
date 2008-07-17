class ApplicationController < ActionController::Base
  include SslRequirement
  include SimpleCaptcha::ControllerHelpers
  
	session :session_key => '_jobs_session_id'
	
  rescue_from(ActiveRecord::RecordInvalid) { template :form, :status => 422 }

protected
  def ensure_proper_protocol
    Rails.env.in?('test', 'development') || super
  end
end