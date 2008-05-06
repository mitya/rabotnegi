class Object
protected
  def logger
    RAILS_DEFAULT_LOGGER
  end
    
  def log(object)
    log_item(object)
  end

  def dump(object)
    log_item(object.inspect)
  end
  
  def log_eval(expr)
    log_item("#{expr} = #{eval(expr)}")
  end  

  def log_eval_class(expr)
    res = eval(expr)
    log_item("#{expr} = #{res == nil ? 'nil' : res}, class = #{res.class}")
  end  

  def dump_eval(expr)
    log_item("#{expr} = #{eval(expr).inspect}")
  end
  
private 
  def log_item(object)
    logger.debug("/// #{file_method_string} #{object}")
  end
  
  def file_method_string
    stack_line_pattern = /.*\/(\w+\.rb):\d+:in `(\w+)'/
    caller_stack_line = caller[2]
    file, method = stack_line_pattern.match(caller_stack_line).captures
    "#{file}::#{method}:"
  end
end
