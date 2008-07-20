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

module SelectHelper
  def list_select_tag(name, collection, selected, options = {})
    option_tags = blank_option_tags(options) + options_for_select(collection, selected)
    content_tag :select, option_tags, { "name" => name, "id" => name }.update(options.stringify_keys)
  end

  def list_group_select_tag(name, collection, selected, options = {})
    option_tags = blank_option_tags(options) + option_groups_from_collection_for_select(collection, :last, :first, :last, :first, selected)
    content_tag :select, option_tags, { "name" => name, "id" => name }.update(options.stringify_keys)
  end

  def select_tag(name, choices, *args)
    if choices.is_a?(String) then super
    elsif choices.first.last.is_a?(Array) then list_group_select_tag(name, choices, *args)
    else list_select_tag(name, choices, *args) end
  end

  # Generates a SELECT tag with option groups.
  # Groups structure is: [[grplabel, [optlabel, opt]], ...]
  def group_select(object, property, groups, options = {})
    ActionView::Helpers::InstanceTag.new(object, property, self, nil, options.delete(:object)).to_group_select_tag(groups, options)
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

  def label_view(name, title, options = {})
    label_tag(name, title + ':', options)
  end
  
  def label_view_for(object, name, title = '', options = {})    
    label(object, name, title + ':', options)
  end  

  def form_view_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!.merge(:builder => WrappedFormBuilder)    
    form_for(record_or_name_or_array, *(args << options), &proc)
  end
  
  def fields_view_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!.merge(:builder => WrappedFormBuilder)
    fields_for(record_or_name_or_array, *(args << options), &proc)
  end
end

module FormViewHelper
  def line(label, content, options = {})
    label = [label]
    content = [content]
    
    row_id = options[:rid]
    row_id = row_id.join('_') if row_id.is_a?(Array)
    
    row_options = {}
    row_options[:id] = "#{row_id}_row" if row_id
    row_options[:class] = "required" if options[:required]
    
    content.unshift options[:before] if options[:before]
    content.push content_tag(:span, '(обязательное поле)', :class => 'required-mark') if options[:required]
    content.push options[:after] if options[:after]
    content.push tag(:br) + content_tag(:small, options[:comment]) if options[:comment]

    content_tag :tr, row_options do
      content_tag(:th, label.join(' ')) +
      content_tag(:td, content.join(' '))
    end
  end
  
  def line_span(content, row_options = {})
    content_tag :tr, row_options do
      content_tag :td, content, :colspan => 2
    end
  end
  
  def left(first, options = {})
    line(first, nil, options)
  end

  def right(last, options = {})
    line(nil, last, options)
  end
    
  def with_label(title, name, options = {})
    wrap_options, content_options = options / [:required, :rid, :before, :after, :label, :comment]
    label = label_view(name, title, wrap_options[:label] || {})
    control = yield(content_options)
    line(label, control, wrap_options.reverse_update(:rid => name))
  end
  
  def text_field_view(title, name, value = nil, options = {})
    with_label(title, name, options) { |options| text_field_tag(name, value, options) }
  end
    
  def password_field_view(title, name, value, options = {})
    with_label(title, name, options) { |options| password_field_tag(name, value, options) }
  end
  
  def select_view(title, name, collection, selected_value, options = {})
    with_label(title, name, options) { |options| select_tag(name, collection, selected_value, options) }   
  end
  
  def list_select_view(title, name, collection, selected_value, options = {})
    with_label(title, name, options) { |options| list_select_tag(name, collection, selected_value, options) }   
  end

  def list_group_select_view(title, name, collection, selected_value, options = {})
    with_label(title, name, options) { |options| list_group_select_tag(name, collection, selected_value, options) }   
  end
  
  def submit_view(title, options = {})
    right(submit_tag(title, options), options.reverse_update(:rid => 'submit'))
  end
  
  def section(options = {}, &block)
    concat(tag(:tbody, options, true), block.binding)
    yield
  end
  
  def wrapper(&block)
    concat("<table class='form-layout'>", block.binding)
    yield
    concat('</table>', block.binding)
  end
end

module FormForHelper
  def with_label_for(title, object_name, method, options)
    wrap_options, content_options = options / [:required, :rid, :before, :after, :label, :comment]
    label = label_view_for(object_name, method, title, wrap_options[:label] || {})
    control = yield(content_options)
    line(label, control, wrap_options.reverse_update(:rid => [object_name, method]))
  end

  def text_field_for(title, object_name, method, options = {})
    with_label_for(title, object_name, method, options) { |opts| text_field(object_name, method, opts) }
  end
  
  def password_field_for(title, object_name, method, options = {})
    with_label_for(title, object_name, method, options) { |opts| password_field(object_name, method, opts) }
  end
  
  def text_area_for(title, object_name, method, options = {})
    with_label_for(title, object_name, method, options) { |opts| text_area(object_name, method, opts) }
  end
  
  def select_for(title, object, method, choices, options = {}, html_options = {})
    with_label_for(title, object, method, options) { |opts| select(object, method, choices, opts, html_options) }
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

  def error_messages(options = {})
    @template.line_span(super(options), :id => 'error_messages_row')
  end  
end

ActionView::Base.default_form_builder = WrappedFormBuilder