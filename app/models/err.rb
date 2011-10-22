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
  
  validates_presence_of :exception_class

  def notify
    # send email to the admin about itself
    ErrMailer.notification(self).deliver
  end

  def to_s
    "#{controller}/#{action} - #{exception_class} - #{exception_message}"
  end

  def self.register(data)
    # log error to the database
    err = create!(data)
    
    # send a notifications if there were less than X emails already sent this hour
    err.notify if where(:created_at.gte => 1.hour.ago).count < MAX_ERR_NOTIFICATIONS_PER_HOUR

    err

  rescue => e
    logger.error "ERROR IN ERROR LOGGING: #{e}"
    logger.error e.backtrace.join("\n")
  end
end
