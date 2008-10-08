def w(object, comment = nil)
  comment &&= "#{comment}: "
  inspection = PP.pp(object, StringIO.new, 100).string rescue object.inspect
  Rails.logger.debug("/// #{comment}#{inspection}")
end

def d(expression, binding = nil)
  l(eval(expression.to_s, binding), expression.to_s)
end
