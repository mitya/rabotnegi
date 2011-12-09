require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Rabotnegi
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/app/plumbing #{config.root}/app/other)
    config.time_zone = 'Moscow'
    config.encoding = "utf-8"
    config.filter_parameters += [:password]   
    
    config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
    
    config.action_controller.cache_store = :file_store, "tmp/cache"

    config.assets.enabled = true
    config.assets.compile = true
    config.assets.precompile += %w(vendor.js admin.css)
    config.assets.version = '1.0'

    config.sass.style = :compact

    # config.mongoid.logger = Logger.new($stdout, :warn)
    config.mongoid.autocreate_indexes = true

    require "ext/core"
    require 'ext/rails'
    require "#{config.root}/app/plumbing/global"

    ::ADMIN_LOGIN = 'admin'
    ::ADMIN_PASSWORD = '0000'
    ::MAX_ERR_NOTIFICATIONS_PER_HOUR = 3
    ::ERR_SENDER = "errors@rabotnegi.ru"
    ::ERR_RECIPIENTS = "dmitry.sokurenko@gmail.com"

    config.after_initialize do  
      ActionView::Base.default_form_builder = CustomFormBuilder
      ActiveSupport::JSON.engine = :json_gem
    end
  end
end
