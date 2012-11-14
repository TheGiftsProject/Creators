require 'active_support/dependencies'
require 'creators/version'
require 'rails/engine'

module Creators
  class Engine < ::Rails::Engine
    initializer 'creators.autoload', :before => :set_autoload_paths do |app|
      app.config.autoload_paths += Dir["#{config.root}/app/creators/**/"]
    end
  end
end

require 'creators/creator'