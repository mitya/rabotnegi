class PureDelegator < ActiveSupport::BasicObject
  def initialize(target)
    @target = target
  end

  def method_missing(selector, *args, &block)
    @target.send(selector, *args, &block)
  end
end
