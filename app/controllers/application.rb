class ApplicationController < ActionController::Base
  include SslRequirement
  include SimpleCaptcha::ControllerHelpers
  
  RecordInvalid = ActiveRecord::RecordInvalid
  RecordNotFound = ActiveRecord::RecordNotFound
  
  rescue_from(RecordInvalid) { template :form, :status => 422 }
  helper :all
  helper_method :current_employer, :current_employer?
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
  
  def current_employer
    @current_employer = Employer.find(session[:employer_id]) if session[:employer_id] unless instance_variable_defined?(:@current_employer)
    @current_employer
  end
  
  def current_employer?
    session[:employer_id].present?
  end
    
  def employer_required
    current_employer || redirect(employers_path)
  end
end