Rabotnegi::Application.configure do  
  config.cache_classes = true
  config.whiny_nils = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = true
  config.action_view.debug_rjs                         = true
  config.action_mailer.raise_delivery_errors = false
end
