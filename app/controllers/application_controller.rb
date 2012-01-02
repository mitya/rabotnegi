# coding: utf-8

class ApplicationController < ActionController::Base
  include SslRequirement
  include SimpleCaptcha::ControllerHelpers
  include ControllerHelper

  # rescue_from(ActiveRecord::RecordInvalid) { render :form, :status => 422 }
  # rescue_from(ActiveRecord::RecordNotFound) { |e|
  #   flash[:error] = "К сожалению, то что вы искали, мы уже куда-то похерили. Если оно вообще здесь было."
  #   redirect_to '/'
  # }
  rescue_from Exception, :with => :handle_unexpected_exception
  
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
    self.admin = Admin.log_in('root', '0000') and return if Rails.env.test?
    authenticate_or_request_with_http_basic do |login, password|
      return true if Rails.env.development?
      login == ADMIN_LOGIN && password == ADMIN_PASSWORD
    end
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
    return @current_user if defined? @current_user
    @current_user = User.find(Encryptor.decrypt(cookies[:uid])) if cookies[:uid].present?
    @current_user
  rescue Mongoid::Errors::DocumentNotFound
    cookies.delete :uid
    nil
  end

  def current_user=(user)
    @current_user = user
    cookies.permanent[:uid] = Encryptor.encrypt(user.id)
  end

  def current_user!
    self.current_user ||= bot? ? User.new : User.create!(browser: request.user_agent, ip_address: request.remote_ip)
  end
  
  def find_model
    selector = model_class.respond_to?(:get) ? :get : :find
    @model = model_class.send(selector, params[:id])
  end
  
  def update_model(model, attributes, url)
    model.attributes = attributes
    if model.save
      redirect_to url, notice: "Изменения сохранены"
    else
      render :edit
    end    
  end
  
  def bot?
    request.user_agent =~ /Googlebot/
  end
  
  def self.model(model_class)
    const_set :Model, model_class
    define_method(:model_class) { model_class }
    define_method(:model_name) { model_class.model_name.element }
    define_method(:model_plural) { model_class.model_name.plural }    
  end
  
  def handle_unexpected_exception(exception)
    return if Rails.env.test? unless $test_error_reporting_enabled
  
    Err.register("#{controller_name}/#{action_name}", exception,
      params: params.except(:controller, :action),
      url: request.url, 
      verb: request.method,
      session: session.to_hash.except('flash'),
      flash: flash.to_hash,
      cookies: cookies.to_a.map(&:first),
      request_headers: request.env.slice(*request.class::ENV_METHODS),
      response_headers: response.headers
    )

    raise exception
  end
  
  helper_method :encode_order
  
  def encode_order(field, reverse_by_default = false, param = params[:sort])
    SortExpressions.encode_order(field, params, reverse_by_default)
  end
  
  def decode_order_to_mongo(param = params[:sort])
    SortExpressions.decode_order_to_mongo(param)
  end  
  
end
