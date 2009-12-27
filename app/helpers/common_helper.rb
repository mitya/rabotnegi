module CommonHelper
	def centered(&proc)
		concat "<table class='centered'><tr><td>"
		yield
		concat '</table>'
	end

	def required_mark(options = {})
    content_tag :span, '(обязательное поле)', {:class => 'required-mark'}.update(options)
	end	
end
