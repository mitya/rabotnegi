class Rails::Rack::Logger < ActiveSupport::LogSubscriber
  REQUEST_LOG_SEPARATOR = Rails.env.production?? ">>> " : "\n\n"
  
  protected
  def before_dispatch(env)
    request = ActionDispatch::Request.new(env)
    path = request.filtered_path

    info "#{REQUEST_LOG_SEPARATOR}Started #{request.request_method} \"#{path}\" " \
         "for #{request.ip} at #{Time.now.to_default_s}"
  end
end
