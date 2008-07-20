module CommonHelper
	def add_css_class(element_id, klass)
		content_tag :script, "$('#{element_id}').addClassName('#{klass}')"
	end
	
	def div(id, options = {}, &proc)
		return if options[:only] == false || options[:except] == true
		
		concat "<div id='#{id}'>", proc.binding
		yield
		concat '</div>', proc.binding
	end

	def center(id, &proc)
		concat "<table id='#{id}' class='centered'><tr><td>", proc.binding
		yield
		concat '</table>', proc.binding
	end
	
	def required_mark(options = {})
    content_tag :span, '(обязательное поле)', {:class => 'required-mark'}.update(options)
	end	
end