# class Logger
#   def format_message(level, time, prog, msg)
#     
#     if level == 'DEBUG'
#       return if msg =~ /^render/i
#       return if msg =~ /missing default helper/i
#     else
#       "#{time.to_s(:db)} #{level} #{msg}\n"
#     end
#   end
# end