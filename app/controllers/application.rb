class ApplicationController < ActionController::Base
  include SslRequirement
  include SimpleCaptcha::ControllerHelpers
  
  rescue_from(ActiveRecord::RecordInvalid) { template :form, :status => 422 }

protected
  def ensure_proper_protocol
    Rails.env.in?('test', 'development') || super
  end
end