class PureDelegator < ActiveSupport::BasicObject
  def initialize(target)
    @target = target
  end

  def call(selector, *args, &block)
    method_missing(selector, *args, &block)
  end

  def method_missing(selector, *args, &block)
    @target.send(selector, *args, &block)
  end
end

module AdvAttrAccessor
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods #:nodoc:
    def adv_attr_accessor(*names)
      names.each do |name|
        ivar = "@#{name}"

        define_method("#{name}=") do |value|
          instance_variable_set(ivar, value)
        end

        define_method(name) do |*parameters|
          raise ArgumentError, "expected 0 or 1 parameters" unless parameters.length <= 1
          if parameters.empty?
            if instance_variable_names.include?(ivar)
              instance_variable_get(ivar)
            end
          else
            instance_variable_set(ivar, parameters.first)
          end
        end
      end
    end
  end
end