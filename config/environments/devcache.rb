Rabotnegi::Application.configure do  
  config.whiny_nils = true
  config.consider_all_requests_local = false
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.serve_static_assets = false
  config.i18n.fallbacks = true

  config.cache_classes = true
  config.log_level = :info
  config.action_controller.perform_caching = true
end
