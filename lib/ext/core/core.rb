class ArgumentNilError < ArgumentError
end
class AssertionError < StandardError
end

class Object
class << self
  def new_private_accessor(*args, &block)
    new(*args, &block).make_private_accessor
  end
end
  
	# call-seq in(enumerable: Enumerable) => bool
	# call-seq in(*objects: Object) => bool
	def in?(*args)
		args.vararg!
		args.include? self
	end
	alias in in?
	
  def exists?
    !blank?
  end
  alias exist? exists?
	
	def getter_name(name) "#{name}".to_sym end
  def setter_name(name) "#{name}=".to_sym end
  def predicate_name(name) "#{name}?".to_sym end
	
	def make_private_accessor
	  PureDelegator.new(self)
	end

private
  # Raises specified event, if handler if defined.
  def event(event_name)
    send(event_name) if respond_to?(event_name)
  end

  def assert(condition)
    condition || raise(AssertionError)
  end

	def raise_if_nil(value, name=nil)
		raise ArgumentNilError, name if value == nil
	end
	
	# nil == '' == '   ' == :'' == :'   '
	# 0 == '0' == '000' == 0.0
	# true == 'true' == 'on' == 'yes'
	def cast_compare(o1, o2)
		return true if o1 == o2
		return true if o1.blank? && o2.blank?
		s1, s2 = o1.to_s.strip, o2.to_s.strip
		return true if s1 == s2
		return false
	end
end

class PureDelegator
  undef_method :instance_variable_get
  undef_method :instance_variable_set
  undef_method :load

  def initialize(target)
    @target = target
  end
  
  def method_missing(method, *args, &block)
    @target.send(method, *args, &block)
  end
end

class Array
  alias count length
  
  def second; self[1] end
  def singleton?; count == 1 end

  def vararg!
    replace(first.to_a) if singleton? && first.is_a?(Enumerable)
  end
end

class Hash
  def select_hash(&proc)
    reject { |k,v| !yield(k,v) }    
  end
  
  def partition_hash(&proc)
    [select_hash(&proc), reject(&proc)]
  end
  
  # split(k1, k2, ...)
  # split([k1, k2, ...])
  def split(*keys)
    keys.vararg!
    partition_hash { |k,| k.in? keys }
  end

  alias count length
  alias / split
  alias + merge

  # Creates difference of this hash and other hash.
  # Returns new hash with value from other hash, which are different in this.
  def diff(other)
    diff = {}
    self.each_key { |k| diff[k] = other[k] if self[k] != other[k] }
    diff
  end
end
 
class String
  def trim_with_ellipsis(letters = 100)
    result = strip
    result.length >= letters ? result[0...letters-1] + '…' : result
  end
end

Time::DATE_FORMATS[:humane] = '%b %d, %Y %H:%M'


class NilClass
  def exists?
    false
  end
end

class Module
private
  def attr_boolean(*names)
    attr_accessor(*names)
    names.each { |n| alias_method "#{n}?".to_sym, n  }
  end
end

class Exception
  def text
    "#{self.class}(#{message})"
  end
end

class Dir
  def [](pattern)
    Dir[path + '/' + pattern]
  end
  
  def create_files(*files)
		files.each { |file| File.new("#{path}/#{file}", 'a') }
  end
end

module Kernel
  def wl(expr, binding = nil)
    result = eval(expr.to_s, binding)
    puts
    puts "#{expr}: #{result.inspect}"
  end
end