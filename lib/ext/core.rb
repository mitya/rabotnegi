module DebugHelper
  def self.reformat_caller(string)
    file, line, method = string.match(/(\w+\.rb):(\d+):in `(\w+)'/).try(:captures)
    "#{file}::#{method}"
  end
end

def __pi(data, label = nil)
  puts "/// #{label} = #{data.inspect}"
end

def __p(*args)
  puts "/// #{args.map(&:inspect).join(", ")}"
end

def __pl(*args)
  location = DebugHelper.reformat_caller(caller.first)
  puts "/// #{location} -- #{args.map(&:inspect).join(", ")}"
end

def __l(*args)
  text = args.length == 1 && String === args.first ? args.first : args.map(&:inspect).join(", ")
  Rails.logger.debug "/// #{text}"
end

def __ll(*args)
  location = DebugHelper.reformat_caller(caller.first)
  Rails.logger.debug "/// #{location} -- #{args.map(&:inspect).join(", ")}"
end

def __a(*args)
  if args.one? && Hash === args.first
    puts Reflector.inspect_hash(args.first) 
  else
    puts '[' + args.map { |a| a.respond_to?(:pid) ? a.pid : a.inspect }.join(", ") + ']'
  end
end

module Kernel
  def assert(*conditions)
    options = conditions.extract_options!
    message = options[:message] || "Assertion Failed"
    message = "Assertion Failed: #{Reflector.inspect_hash(message)}" if Hash === message
    conditions.each { |condition| raise message unless condition }
  end
  
  def mai
    Mai
  end
end

class Object
  alias is? is_a?
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
