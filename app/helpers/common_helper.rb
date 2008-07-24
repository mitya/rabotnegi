module CommonHelper
	def add_css_class(element_id, klass)
		content_tag :script, "$('#{element_id}').addClassName('#{klass}')"
	end
	
	def div(id, options = {}, &proc)
		return if options[:only] == false || options[:except] == true
		
		concat "<div id='#{id}'>"
		yield
		concat '</div>'
	end

	def center(id, &proc)
		concat "<table id='#{id}' class='centered'><tr><td>"
		yield
		concat '</table>'
	end
	
	def required_mark(options = {})
    content_tag :span, '(обязательное поле)', {:class => 'required-mark'}.update(options)
	end	
end