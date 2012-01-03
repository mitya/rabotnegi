Rabotnegi::Application.configure do
  config.cache_classes = true
  config.whiny_nils = true
  config.action_dispatch.show_exceptions = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = false
  config.action_controller.allow_forgery_protection    = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :stderr

  # Allow pass debug_assets=true as a query parameter to load pages with unpackaged assets
  config.assets.allow_debugging = true

  Se.rabotaru_dir = "rabotaru-test"
  
  config.after_initialize do
    Resque.inline = true
  end
end
