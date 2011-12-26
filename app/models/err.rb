class Err < ApplicationModel
  field :source
  field :host
  field :params, type: Hash
  field :exception_class
  field :exception_message
  field :backtrace

  field :controller
  field :action

  field :url
  field :verb
  field :session, type: Hash
  field :cookies, type: Array
  field :request_headers, type: Hash
  field :response_headers, type: Hash

  index :created_at

  validates_presence_of :exception_class

  def source
    self[:source] || "#{controller}/#{action}"
  end

  def notify
    ErrMailer.notification(self).deliver
  end

  def to_s
    "#{source} - #{exception_class} - #{exception_message}"
  end

  class << self
    def register(source, exception, data = {})
      puts(exception) if Rails.env.development?
    
      data.update(
        source: source,
        host: Socket.gethostname, 
        time: Time.now,
        exception_class: exception.class.name,
        exception_message: exception.message,
        backtrace: exception.backtrace.join("\n")
      )
    
      err = logger.silence { create!(data) }
      err.notify if recent_errors_count < MAX_ERR_NOTIFICATIONS_PER_HOUR
      err

    rescue => e
      logger.error "ERROR IN ERROR LOGGING: #{e}"
      logger.error e.backtrace.join("\n")
    end

    def query(params)
      params = params.symbolize_keys
      params.assert_valid_keys(:q)
      query = Regexp.new(params[:q] || "", true)

      scope = self
      scope = scope.any_of({exception_class: query}, {exception_message: query}, {url: query}) if params[:q].present?
      scope
    end
  
    def puts(error)
      message = gg.format_error_and_stack(error)

      # logger.error "ERROR #{exception.class}: #{exception.message}"
      # logger.error Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")

      logger.error(message)
      STDERR.puts(message)
    end
  
    def recent_errors_count(since = 1.hour.ago)
      where(:created_at.gte => since).count
    end    
  end
end
