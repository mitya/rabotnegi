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
    # config.mongoid.autocreate_indexes = true

    require 'fileutils'
    require 'ostruct'
    require "ext/core"
    require 'ext/rails'
    require "#{config.root}/app/plumbing/global"

    ::Se = OpenStruct.new
    Se.admin_login = 'admin'
    Se.admin_password = '0000'
    Se.err_max_notifications_per_hour = 3
    Se.err_sender = "errors@rabotnegi.ru"
    Se.err_recipients = "dmitry.sokurenko@gmail.com"
    Se.rabotaru_dir = "rabotaru"
    Se.default_queue = :main
    
    config.after_initialize do  
      ActionView::Base.default_form_builder = CustomFormBuilder
      ActiveSupport::JSON.engine = :json_gem

      # Resque.redis = "localhost:6379"
      Resque.redis.namespace = "rabotnegi:jobs"
    end
    
    config.to_prepare do
      Mai # load it
    end
  end
end
