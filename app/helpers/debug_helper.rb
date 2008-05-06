module DebugHelper
	def dump(obj)
		result = ''
		result << '<h3>Public</h3>'
		result << dump_methods(obj, obj.public_methods).inject(''){|r, m| r << m + '<br>'}
		
		result << '<h3>Protected</h3>'
		result << dump_methods(obj, obj.protected_methods).inject(''){|r, m| r << m + '<br>'}

		result << '<h3>Private</h3>'
		result << dump_methods(obj, obj.private_methods).inject(''){|r, m| r << m + '<br>'}
		
		result
	end
	
private
	def dump_methods(obj, method_names)
		method_names.map{|m| obj.method m}.sort_by{|m| m.to_s}.map {|m|
			@@method_pattern =~ m.to_s
			if $3.ends_with?('=') || m.arity==0
				params = ''
			elsif m.arity==-1
				params = '/*'
			elsif m.arity<-1
				params = "/#{-m.arity-1}*"
			else
				params = "/#{m.arity}" end
			"#{$2 || $1}.#{$3}#{params}"
		}
	end
	
	@@method_pattern = /#<Method: (\w+)(\(.+\))?#(.+)>/
end