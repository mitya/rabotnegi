Rabotnegi::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  config.log_level = :info

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
end
