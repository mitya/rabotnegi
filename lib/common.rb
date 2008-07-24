def assert(condition, message = "Assertion failed")
  condition || raise(mesage)
end

class PureDelegator < ActiveSupport::BasicObject
  def initialize(target)
    @target = target
  end

  def method_missing(method, *args, &block)
    @target.send(method, *args, &block)
  end
end

Time::DATE_FORMATS[:humane] = '%b %d, %Y %H:%M'