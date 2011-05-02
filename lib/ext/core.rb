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
  location = DebugHelper.reformat_caller(caller.first)
  puts "/// #{location} -- #{args.map(&:inspect).join(", ")}"
end

def __l(*args)
  location = DebugHelper.reformat_caller(caller.first)
  Rails.logger.debug "DEBUG #{location} -- #{args.map(&:inspect).join(", ")}"
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
end
