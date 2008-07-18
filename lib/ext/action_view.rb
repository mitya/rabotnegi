class ActionView::Base
  def partial(partial, options = {})
    controller.partial(partial, options)
  end    
end

class ActionView::Helpers::InstanceTag
  def to_group_select_tag(groups, options)
    rails_options, html_options = options.split(:selected, :include_blank, :prompt, :object)
    html_options.stringify_keys!
    add_default_name_and_id(html_options)
    value = value(object)
    selected_value = rails_options.has_key?(:selected) ? rails_options[:selected] : value
    inner_html = option_groups_from_collection_for_select(groups, :last, :first, :last, :first, selected_value)
    content_tag("select", add_options(inner_html, rails_options, selected_value), html_options)
  end
end

module FormHelperExtensions
  def submit_section(action_label)
    <<-html
  		<div class='submit'>
  			<input type="submit" class='action-button' value='#{action_label}'>
  			<span class='cancel'>
  				или
  				<a href='#{ request.headers['Referer'] }' class='ui'>Отменить</a>
  			<span>
  		</div>
  	html
	end
  
  def label_tag(target, title, options = {})
	  content_tag :label, title + ':', { "for" => target }.update(options.stringify_keys)
	end
  
  def single_select_tag(name, choices, selected_value, options = {})
    option_tags = blank_option_tags(options) + options_for_select(choices, selected_value)
    content_tag :select, option_tags, { "name" => name, "id" => name }.update(options.stringify_keys)
  end
  
  def group_select_tag(name, choices, selected_value, options = {})
    option_tags = blank_option_tags(options) + option_groups_from_collection_for_select(choices, :last, :first, :last, :first, selected_value)
    content_tag :select, option_tags, { "name" => name, "id" => name }.update(options.stringify_keys)
  end
  
  def select_tag(name, choices, *args)
    if choices.is_a?(String) then super
    elsif choices.first.last.is_a?(Array) then group_select_tag(name, choices, *args)
    else single_select_tag(name, choices, *args) end
  end
  
  # Generates <select> tag with option groups
  # groups is [[grplabel, [optlabel, opt]], ...]
  def group_select(object, property, groups, options = {})
    ActionView::Helpers::InstanceTag.new(object, property, self, nil, options.delete(:object)).to_group_select_tag(groups, options)
  end
  
  def select(object, method, choices, options = {}, html_options = {})
    choices.first.last.is_a?(Array) ? group_select(object, method, choices, options) : super
  end
  
private
  def blank_option_tags(options = {})
    blank = options[:blank]
    prompt = options[:prompt]
    
    option_tags = ''
    option_tags << content_tag(:option) if blank == true
    option_tags << content_tag(:option, blank) if blank.is_a? String
    option_tags << content_tag(:option, blank.first, :value => blank.last) if blank.is_a? Array
    option_tags << content_tag(:option, prompt) if prompt
    option_tags
  end
end

module WrappedFormTagHelper
  # Like #form_for, but generate layout table inside
  def form(record_or_name_or_array, *args, &proc)
    raise ArgumentError, "Missing block" unless block_given?

    options = args.extract_options!
    options[:builder] = WrappedFormBuilder

    case record_or_name_or_array
    when String, Symbol
      object_name = record_or_name_or_array
    when Array
      object = record_or_name_or_array.last
      object_name = ActionController::RecordIdentifier.singular_class_name(object)
      apply_form_for_options!(record_or_name_or_array, options)
      args.unshift object
    else
      object = record_or_name_or_array
      object_name = ActionController::RecordIdentifier.singular_class_name(object)
      apply_form_for_options!([object], options)
      args.unshift object
    end

    concat(form_tag(options.delete(:url) || {}, options.delete(:html) || {}), proc.binding)
	  concat("<table class='form-layout'>", proc.binding)
    fields_for(object_name, *(args << options), &proc)
	  concat('</table>', proc.binding)
    concat('</form>', proc.binding)
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


class WrappedFormBuilder < ActionView::Helpers::FormBuilder
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
