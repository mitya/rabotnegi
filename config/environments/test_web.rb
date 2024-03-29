Rabotnegi::Application.configure do
  config.log_level = :debug
  config.cache_classes = true
  config.whiny_nils = true
  config.action_dispatch.show_exceptions = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = false
  config.action_controller.allow_forgery_protection    = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :stderr
end
