class Object
  def define_constant_methods(hash)
    hash.each_pair do |method, value|
      metaclass.send(:define_method, method) { value }
    end
  end
end

class Array
  # Returns first element when there is only one element, otherwise returns self.
  def reduce
    size == 1 ? first : self
  end
end

class Hash
  def partition_by(*keys)
    [slice(keys), except(keys)]
  end
end