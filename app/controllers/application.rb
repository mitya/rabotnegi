class ApplicationController < ActionController::Base
  include SslRequirement
  include SimpleCaptcha::ControllerHelpers
  
  rescue_from(ActiveRecord::RecordInvalid) { template :form, :status => 422 }

protected
  def log_processing
    if logger && logger.info?
      logger.info  "\n\nProcessing #{self.class.name}\##{action_name} (for #{request_origin}) [#{request.method.to_s.upcase}]"
      logger.info  "  Session ID: #{@_session.session_id.inspect}" if @_session and @_session.respond_to?(:session_id)
      logger.info  "  Parameters: #{respond_to?(:filter_parameters) ? filter_parameters(params).inspect : params.inspect}"
      logger.debug "  Session: #{session.instance_variable_get(:@data).inspect}"
      # logger.debug "  Cookies: #{cookies.inspect}"
    end
  end

  def ensure_proper_protocol
    ['test', 'development'].include?(Rails.env) || super
  end
end