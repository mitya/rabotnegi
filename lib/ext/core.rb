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

class Module
  def def_state_predicates(storage, *states)
    module_eval <<-ruby    
      def self._state_attr
        :#{storage}
      end
    ruby
    
    states.each do |state|
      module_eval <<-ruby
        def #{state}?
          self.#{storage} == :#{state} || self.#{storage} == '#{state}'
        end
      ruby
    end
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
