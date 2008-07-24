class Object
  def present?
    !blank?
  end

  def metaclass
    class << self; self end
  end

  def define_constant_methods(hash)
    hash.each_pair do |method, value|
      metaclass.send(:define_method, method) { value }
    end
  end
end

class Array
  def second
    self[1]
  end

  def reduce
    size == 1 ? first : self
  end
end

class Hash
  def partition_by(*keys)
    [slice(keys), except(keys)]
  end
end