# coding: utf-8

module CommonHelper
	def centered(&proc)
	  "<table class='centered'><tr><td>#{capture(&proc)}</table>".html_safe
	end

	def required_mark(options = {})
    content_tag :span, '(обязательное поле)', {:class => 'required-mark'}.update(options)
	end	
	
	def edit_icon
	  image_tag 'edit.gif', :title => 'Редактировать', :alt => 'Редактировать'
	end
	
	def delete_icon
	  image_tag 'delete.gif', :title => 'Удалить', :alt => 'Удалить'
	end
end
