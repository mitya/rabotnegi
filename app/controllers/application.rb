class ApplicationController < ActionController::Base
  include SslRequirement
  include SimpleCaptcha::ControllerHelpers
  
  rescue_from(ActiveRecord::RecordInvalid) { template :form, :status => 422 }
  helper :all
  before_filter :set_locale

protected
  def log_processing
    super
    logger.debug "  Session: #{session.instance_variable_get(:@data).inspect}"
  end

  def ensure_proper_protocol
    Rails.env.development? || Rails.env.test? || super
  end
  
  def set_locale
    I18n.locale = 'ru-RU'
  end
end