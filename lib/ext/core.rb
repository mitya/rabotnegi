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


# module ActiveSupport
#   module JSON
#     module Encoding
#       class << self
#         def escape(string)
#           # if string.respond_to?(:force_encoding)
#           #   string = string.encode(::Encoding::UTF_8, :undef => :replace).force_encoding(::Encoding::BINARY)
#           # end
#           # json = string.
#           #   gsub(escape_regex) { |s| ESCAPED_CHARS[s] }.
#           #   gsub(/([\xC0-\xDF][\x80-\xBF]|
#           #          [\xE0-\xEF][\x80-\xBF]{2}|
#           #          [\xF0-\xF7][\x80-\xBF]{3})+/nx) { |s|
#           #   s.unpack("U*").pack("n*").unpack("H*")[0].gsub(/.{4}/n, '\\\\u\&')
#           # }
#           json = %("#{string}")
#           # json.force_encoding(::Encoding::UTF_8) if json.respond_to?(:force_encoding)
#           # json
#         end      
#       end
#     end    
#   end
# end
