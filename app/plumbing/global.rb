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
    puts Reflector.hash_view(args.first) 
  else
    puts '[' + args.map { |a| a.respond_to?(:pid) ? a.pid : a.inspect }.join(", ") + ']'
  end
end

def assert(*conditions)
  options = conditions.extract_options!
  message = options[:message] || "Assertion Failed"
  message = "Assertion Failed: #{Reflector.hash_view(message)}" if Hash === message
  conditions.each { |condition| raise message unless condition }
end

def mai
  Mai
end
