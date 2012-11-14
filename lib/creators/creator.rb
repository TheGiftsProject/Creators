require 'active_support/core_ext'

# Creators are used to host code dealing with creation of new models and clean up the controllers.
#
# EXAMPLE:
#  class SomeCreator
#    def refine_params
#      # a hash with refined parameters required for the model.
#    end
#  end
#
#  class SomeController
#    def action
#      model = SomeCreator.new(params)
#      if model.save
#        # good flow
#      else
#        # bad flow
#      end
#    end
#  end
module Creators
  class Base

    class ErrorInParams < StandardError;end

    def self.inherited(child_class)
      child_class.class_eval do
        class_name = child_class.to_s.gsub('Creator', '')
        define_method :klass do
          class_name.constantize
        end

        define_method class_name.underscore do
          model
        end
      end
    end

    def initialize(raw_params = {}, model = nil)
      @params = raw_params
      @model  = model
      @errors = {}
    end

    def save
      build
      before_save
      return false unless @model.save
      after_save
      true
    rescue ErrorInParams => e
      Log.error(e)
      false
    end

    def model
      @model
    end

    def errors
      e = @errors
      return e.merge(@model.errors()) if @model.present? and @model.errors().present?
      e
    end

    def error(field, text)
      @errors[field] = text
      raise ErrorInParams.new("#{field}: #{text}")
    end

    protected

    def build
      before_build
      build_model
      after_build
    end

    def build_model
      @model ||= klass.new()
      @model.attributes = refine_params
    end

    def refine_params
      @params
    end

    def before_build
    end

    def after_build
    end

    def before_save
    end

    def after_save
    end
  end
end