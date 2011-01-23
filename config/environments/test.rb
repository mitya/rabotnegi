Rabotnegi::Application.configure do
  config.cache_classes = true
  config.whiny_nils = true
  
  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  config.consider_all_requests_local = true
  config.action_controller.perform_caching             = false
  config.action_controller.allow_forgery_protection    = false
  
  config.action_mailer.delivery_method = :test
  
  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
end
