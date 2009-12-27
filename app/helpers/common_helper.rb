module CommonHelper
	def div(id, options = {}, &proc)
		return if options[:only] == false || options[:except] == true
		
		concat "<div id='#{id}'>"
		yield
		concat '</div>'
	end

	def centered(&proc)
		concat "<table class='centered'><tr><td>"
		yield
		concat '</table>'
	end
	
	def required_mark(options = {})
    content_tag :span, '(обязательное поле)', {:class => 'required-mark'}.update(options)
	end	
end
