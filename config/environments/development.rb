Rabotnegi::Application.configure do
  config.cache_classes = false
  config.whiny_nils = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.action_mailer.delivery_method = :test
  config.action_mailer.smtp_settings = YAML.load_file("/volumes/code/config/smtp.yml").to_options

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  config.log_level = :debug

  # Only use best-standards-support built into browsers
  config.action_dispatch.show_exceptions = true
  config.action_dispatch.best_standards_support = :builtin

  config.assets.compress = false
  config.assets.debug = true

  config.after_initialize do
    Slim::Engine.set_default_options pretty: true
    # Resque.inline = false
  end
  
  # config.cache_classes = true
  # config.log_level = :info
  # config.action_controller.perform_caching = true
end
