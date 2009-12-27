class ApplicationController < ActionController::Base
  include SslRequirement
  include SimpleCaptcha::ControllerHelpers
  include HoptoadNotifier::Catcher
  
  RecordInvalid = ActiveRecord::RecordInvalid
  RecordNotFound = ActiveRecord::RecordNotFound
  
  rescue_from(RecordInvalid) { template :form, :status => 422 }
  rescue_from(RecordNotFound) { flash[:error] = "К сожалению, то что вы искали, мы уже куда-то похерили. Если оно вообще здесь было."; redirect '/' }
  helper :all
  helper_method :current_employer, :current_employer?
  before_filter :set_locale

protected
  def log_processing
    super
    # logger.debug "  Session: #{session.instance_variable_get(:@data).inspect}"
  end

  def ensure_proper_protocol
    Rails.env.development? || Rails.env.test? || super
  end
  
  def set_locale
    I18n.locale = 'ru'
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

  def admin_required
    self.admin = Admin.log_in('root', '0000') and return if Rails.env.test?
    authenticate_or_request_with_http_basic do |login, password|
      login == ADMIN_LOGIN && password == ADMIN_PASSWORD
    end
  end  
end