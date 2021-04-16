require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Dmr
  class Application < Rails::Application
    
    config.load_defaults 6.1
    
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local
    config.active_record.schema_format = :sql
    
  end
end