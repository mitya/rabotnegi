Rabotnegi::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  syslog_facility = ENV["RAILS_PROC"].presence || "web" 
  config.logger = SyslogLogger.new("rab-#{syslog_facility}", Syslog::LOG_USER, Syslog::LOG_PID)
  config.log_level = :info

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: "rabotnegi.ru" }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    user_name: "railsapp",
    password: "00005555",
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
  
  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  config.assets.compress = false
  config.assets.compile = true
  config.assets.digest = true
  # config.assets.manifest = YOUR_PATH

  GOOGLE_ANALYTICS_ID = "UA-1612812-2"
end
