class Err
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :controller 
  field :action
  field :url
  field :verb
  field :host
  field :session, type: Hash
  field :params, type: Hash
  field :exception_class
  field :exception_message
  field :cookies, type: Array
  field :request_headers, type: Hash
  field :response_headers, type: Hash
  field :backtrace
  
  index :created_at

  def notify
    # send email to the admin about itself
    ErrMailer.notification(self).deliver
  end

  def to_s
    "#{controller}/#{action} - #{exception_class} - #{exception_message}"
  end

  def self.register(data)
    # log error to the database
    err = create!(
      controller: controller_name, 
      action: action_name, 
      url: request.url, 
      verb: request.method,
      host: Socket.gethostname, 
      session: session, 
      params: params.except(:controller, :action), 
      exception_class: exception.class.name,
      exception_message: exception.message,
      cookies: cookies.to_a.map(&:first),
      backtrace: exception.backtrace.join("\n"),
      request_headers: request.env.slice(*request.class::ENV_METHODS),
      response_headers: response.headers
    )
    
    # send a notifications if there were less than X emails already sent this hour
    err.notify if where(:created_at.gte => 1.hour.ago).count < MAX_ERR_NOTIFICATIONS_PER_HOUR

  rescue => e
    logger.error "ERROR IN ERROR LOGGING: #{e}"
    logger.error e.backtrace.join("\n")
  end
end
