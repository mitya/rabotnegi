def assert(condition, message = "Assertion failed")
  condition || raise(mesage)
end

# __w(customer.name, "Customer") => /// Customer = "Joe"
# __w(customer.name) => /// "Joe"
def __w(object, comment = nil)
  comment &&= "#{comment} = "
  inspection = PP.pp(object, StringIO.new, 100).string rescue object.inspect
  Rails.logger.debug("/// #{comment}#{inspection}")
end

# __d(customer.name, binding) => /// customer.name = "Joe"
# __d(@customer.name) => /// @customer.name = "Joe"
def __d(expression, binding = nil)
  value = eval(expression.to_s, binding)
  __w(value, expression.to_s)
end
