Rabotnegi::Application.configure do
  config.log_level = :debug
  config.cache_classes = true
  config.action_controller.consider_all_requests_local = false
  config.action_controller.perform_caching             = true

  GOOGLE_ANALYTICS_ID = "UA-1612812-2"
end
