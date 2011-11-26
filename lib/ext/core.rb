class Object
  def is?(*types)
    types.any? { |type| self.is_a?(type) }
  end
  
  def assign_attributes(attributes)
    attributes.each_pair { |k,v| send("#{k}=", v) if respond_to?("#{k}=") } if attributes
  end  

  def assign_attributes!(attributes)
    attributes.each_pair { |k,v| send("#{k}=", v) } if attributes
  end  
end

class Hash
  def append_string(key, text)
    self[key] ||= ""
    self[key] = self[key].present?? self[key] + ' ' + text.to_s : text.to_s
  end

  def prepend_string(key, text)
    self[key] ||= ""
    self[key] = self[key].present?? text.to_s + ' ' + self[key] : text.to_s
  end
end

class Time
  def to_json(*args)
    as_json.to_json
  end
end

class BSON::ObjectId
  def to_json(*args)
    as_json.to_json
  end  
end
