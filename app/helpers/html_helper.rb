module HtmlHelper
	def sort_sign(field)
		return "" if field != @sort_field
		return "▲" if @sort_direction == :asc
		return "▼" if @sort_direction == :desc
  end

	def sort_parameter(field)
		return {$sort_param_name => field.to_s} if field != @sort_field
		return {$sort_param_name => "-" + field.to_s} if @sort_direction == :asc
		return {$sort_param_name => field.to_s}	if @sort_direction == :desc
	end
	
	def sort_link(label, field)
		link_to(
			"<span class='sort-mark'>#{sort_sign(field)}</span>"+label,
			request.request_parameters.merge(sort_parameter(field).merge({$page_param_name=>nil})),
			{:class=>'ui'}) 
	end
	
	def add_css_class(element_id, klass)
		content_tag 'script', "$('#{element_id}').addClassName('#{klass}')", :type=>'text/javascript'
	end
	
	def div(id, options = {}, &proc)
		return if options[:only] == false
		return if options[:except] == true
		
		if options[:center]
			concat "<table id='#{id}' class='centered'><tr><td>", proc.binding
			yield
			concat '</table>', proc.binding
    else
  		concat "<div id='#{id}'>", proc.binding
  		yield
  		concat '</div>', proc.binding
		end
	end
	
	def message(id, object)
		return if !object
		content_tag 'div', object, :id => id
	end
	
	def objects_found(paginator, objects, word, e1, e2, e5)
		if paginator.page_count <= 1
			count = objects.size
			object = RussianInflector.inflect objects.size, word, e1, e2, e5
		else
			count = "более #{paginator.page_count * 50}"
			object = RussianInflector.inflect paginator.page_count * 50, word, e1, e2, e5, :more end
		"<span class='search-result-count'>#{count}</span> #{object}"
	end
	
	def submit_section(action_label)
    %{
  		<div class='submit'>
  			<input type="submit" class='action-button' value='#{action_label}'>
  			<span class='cancel'>
  				или
  				<a href='#{ request.env['HTTP_REFERER'] }' class='ui'>Отменить</a>
  			<span>
  		</div>
  	}
	end
	

	
	def extract_wrap_options(options)
	  wrap_options, content_options = options.split(:required, :rid, :before, :after, :label, :comment)
	  label_options = wrap_options[:label] || {}
	  [wrap_options, content_options, label_options]
	end
	
	def wrap_in_line(label, content, options = {})
	  label = [label]
	  content = [content]
	  
	  row_id = options[:rid]
	  row_id = row_id.join('_') if row_id.is_a? Array
	  
	  row_options = {}
	  row_options[:id] = "#{row_id}_row" if row_id
	  row_options[:class] = "required" if options[:required]
	  
    content.unshift options[:before] if options[:before]
    content.push content_tag(:span, '(обязательное поле)', :class => 'required-mark') if options[:required]
    content.push options[:after] if options[:after]
    content.push '<br>' + content_tag(:small, options[:comment]) if options[:comment]

		content_tag :tr, row_options do
		  content_tag(:th, label.join(' ')) +
		  content_tag(:td, content.join(' '))
		end
	end
	
	def wrap_in_full_line(content, row_options = {})
	  content_tag :tr, row_options do
	    content_tag :td, content, :colspan => 2
	  end
	end
	
	def password_field_el(title, name, value, options = {})
	  label = label_tag(name, title)
	  control = password_field_tag(name, value, options)
	  wrap_in_line(label, control, :rid => name)
	end
	
	def text_field_el(title, name, value = nil, options = {})
	  label = label_tag(name, title)
	  control = text_field_tag(name, value, options)
	  wrap_in_line(label, control, :rid => name)
	end
	
	def select_el(title, name, choices, selected_value, options = {})
	  label = label_tag(name, title)
	  control = select_tag(name, choices, selected_value, options)
	  wrap_in_line(label, control, :rid => name)
	end
	
	def submit_el(title, options = {})
	 control = submit_tag(title, options)
	 wrap_in_line(nil, control, :rid => 'submit')
	end
	alias submit_for submit_el
	
	
	def form_el(*args, &proc)
	  options = args.extract_options!
	  self_options, super_options = options.split(:fieldset)
	  concat(form_tag(*(args << super_options)), proc.binding)
	  concat("<fieldset>", proc.binding) if self_options[:fieldset]
	  concat("<table class='form-layout'>", proc.binding)
    yield
	  concat('</fieldset>', proc.binding) if self_options[:fieldset]
	  concat('</table>', proc.binding)
	  concat('</form>', proc.binding)
	end
	
	def password_field_for(title, object_name, method, options = {})
	  label = label(object_name, method, title+':')
	  control = password_field(object_name, method, options)
	  wrap_in_line(label, control, {:rid => [object_name, method]}.merge(options))
	end
	
	def text_field_for(title, object_name, method, options = {})
	  wrap_options, control_options, label_options = extract_wrap_options(options)
	  label = label(object_name, method, title+':', label_options)
	  control = text_field(object_name, method, control_options)
	  wrap_in_line(label, control, {:rid => [object_name, method]}.merge(wrap_options))
	end
	
	def text_area_for(title, object_name, method, options = {})
	  label = label(object_name, method, title+':')
	  control = text_area(object_name, method, options)
	  wrap_in_line(label, control, {:rid => [object_name, method]}.merge(options))
	end
	
	def select_for(title, object, method, choices, options = {}, html_options = {})
	  wrap_in_line(
	    label(object, method, title + ':', options),
	    select(object, method, choices, options, html_options),
	    :rid => [object, method])
	end
	
	def field_set(options = {}, &block)
    concat(tag(:tbody, options, true), block.binding)
	  yield
  end
		
private
	def selected value, default
		cast_compare(value, default) ? ' selected' : nil
	end
end

class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(title, *args)
    @template.text_field_for(title, @object_name, *args)
  end
  
  def password_field(title, *args)
    @template.password_field_for(title, @object_name, *args)
  end
  
  def text_area(title, *args)
    @template.text_area_for(title, @object_name, *args)
  end
  
  def select(title, *args)
    @template.select_for(title, @object_name, *args) 
  end
  
  def submit(*args)
    @template.submit_el(*args)
  end
  
  def field_set(title = nil, id = nil, options = {}, &proc)
    defaults = {}
    defaults[:id] = "#{object_name}_#{id}" if id
    # defaults[:title] = title if title
    @template.field_set(defaults.update(options), &proc)
  end
  
  def wrap(last, options = {})
    @template.wrap_in_line(nil, last, options)
  end
  
  def wrap2(first, last, options = {})
    @template.wrap_in_line(@template.label_tag(nil, first), last, options)
  end
    
  def submit_section(title, options = {})
    wrap(@template.submit_section(title), options)
  end
  
  def error_messages(options = {})
    @template.wrap_in_full_line(super(options), :id => 'error_messages_row')
  end
end