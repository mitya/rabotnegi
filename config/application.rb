require File.expand_path('../boot', __FILE__)

require 'rails/all'

# require "action_controller/railtie"
# require "action_mailer/railtie"
# require "active_resource/railtie"
# require "rails/test_unit/railtie"

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Rabotnegi
  class Application < Rails::Application
    config.action_controller.cache_store = :file_store, "tmp/cache"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]   

    require "ext/core"
    require 'ext/rails'
    require 'ext/libs'
    require 'utilities'

    # config.mongoid.logger = Logger.new($stdout, :warn)
    # config.mongoid.autocreate_indexes = true

    config.after_initialize do  
      ActionView::Base.default_form_builder = CustomFormBuilder
      
      ActiveSupport::JSON.backend = "JSONGem"
      
      Sass::Plugin.options[:style] = :compact
      Sass::Plugin.options[:template_location] = "#{config.root}/app/stylesheets"
      Sass::Plugin.options[:css_location] = "#{config.root}/public/stylesheets/gen"

      Haml::Template::options[:ugly] = true

      ADMIN_LOGIN = 'admin'
      ADMIN_PASSWORD = '0000'
    end
  end
end
