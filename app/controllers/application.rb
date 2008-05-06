class ApplicationController < ActionController::Base
  include SslRequirement
  include SimpleCaptcha::ControllerHelpers
  
	session :session_key => '_jobs_session_id'
	helper :debug, :html
	before_filter :init_flash_trace

private
	def init_flash_trace
		flash[:trace] = {}
	end
end

$page_size = 50
$sort_param_name  = 's'
$page_param_name  = 'p'
$query_param_name = 'q'