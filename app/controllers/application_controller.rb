# coding: utf-8

class ApplicationController < ActionController::Base
  include SslRequirement
  include SimpleCaptcha::ControllerHelpers
  include ControllerHelper
  
  rescue_from(ActiveRecord::RecordInvalid) { render :form, :status => 422 }
  rescue_from(ActiveRecord::RecordNotFound) { |e|
    Rails.logger.debug(e)
    flash[:error] = "К сожалению, то что вы искали, мы уже куда-то похерили. Если оно вообще здесь было."
    redirect_to '/'
  }
  helper :all
  before_filter :set_locale
  
  delegate :benchmark, :to => ActionController::Base

  protect_from_forgery
  
  Encryptor = ActiveSupport::MessageEncryptor.new(Rabotnegi::Application.config.secret_token)

protected

  def ensure_proper_protocol
    Rails.env.development? || Rails.env.test? || super
  end
  
  def set_locale
    I18n.locale = 'ru'
  end
  
  def employer_required
    current_employer || redirect_to(employer_path)
  end

  def admin_required
    # self.admin = Admin.log_in('root', '0000') and return if Rails.env.test?
    # authenticate_or_request_with_http_basic do |login, password|
    #   login == ADMIN_LOGIN && password == ADMIN_PASSWORD
    # end
  end  
  
  def resume_required
    current_resume || redirect_to(worker_login_path)
  end

  helper_method :current_employer, :current_user!

  def current_employer
    return @current_employer if defined? @current_employer
    @current_employer = session[:employer_id] ? Employer.get(session[:employer_id]) : nil
  end
  
  def current_resume
    return @current_resume if defined? @current_resume
    resume_id = session[:resume_id] || cookies[:resume_id]
    if @current_resume = resume_id ? Resume.get(resume_id) : nil
      session[:resume_id] = @current_resume.id
      cookies[:resume_id] = @current_resume.id
    else
      session[:resume_id] = nil
      cookies.delete(:resume_id)
    end
    @current_resume
  end

  def current_user
    unless defined?(@current_user)
      @current_user = User.find(Encryptor.decrypt(cookies[:uid])) if cookies[:uid].present?
    end
    @current_user
  end

  def current_user=(user)
    @current_user = user
    cookies.permanent[:uid] = Encryptor.encrypt(user.id)
  end

  def current_user!
    self.current_user ||= User.create!
  end
end
