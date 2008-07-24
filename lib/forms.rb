module SelectHelper
  def list_select_tag(name, collection, selected, options = {})
    option_tags = blank_option_tags(options) + options_for_select(collection, selected)
    content_tag :select, option_tags, { "name" => name, "id" => name }.update(options.stringify_keys)
  end

  def list_group_select_tag(name, collection, selected, options = {})
    option_tags = blank_option_tags(options) + option_groups_from_collection_for_select(collection, :last, :first, :last, :first, selected)
    content_tag :select, option_tags, { "name" => name, "id" => name }.update(options.stringify_keys)
  end

  # Generates a SELECT tag with option groups.
  # Groups structure is: [[grplabel, [optlabel, opt]], ...]
  def group_select(object, property, groups, options = {})
    ActionView::Helpers::InstanceTag.new(object, property, self, nil, options.delete(:object)).to_group_select_tag(groups, options)
  end

  def blank_option_tags(options = {})
    blank = options.delete(:blank)
    prompt = options.delete(:prompt)

    option_tags = ''
    option_tags << content_tag(:option) if blank == true
    option_tags << content_tag(:option, blank) if blank.is_a?(String)
    option_tags << content_tag(:option, blank.first, :value => blank.last) if blank.is_a?(Array)
    option_tags << content_tag(:option, prompt) if prompt
    option_tags
  end  
end

module FormHelperExtensions
  def submit_section(label)
    %{<div class='submit'>
        <input type="submit" class='action-button' value='#{ label }'>
        <span class='cancel'>
          или
          <a href='#{ request.headers['Referer'] }' class='ui'>Отменить</a>
        <span>
      </div>}
  end  
end

module FormViewHelper
  # Options: :required, :id, :before, :after, :comment
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
  
  def line_left(first, options = {})
    line(first, nil, options)
  end

  def line_right(last, options = {})
    line(nil, last, options)
  end
  
  def line_for(name, title, content, options = {})
    label = label_tag(name, title + ':')
    line(label, content, options)
  end
    
  def section(options = {}, &block)
    concat(tag(:tbody, options, true), block.binding)
    yield
  end
  
  def wrapper(&block)
    concat "<table class='form-layout'>", block.binding
    yield
    concat '</table>', block.binding
  end
end

class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def line_for(property, title, content, options = {})
    label = label(property, title + ':')
    @template.line(label, content, options)
  end
end	

ActionView::Base.default_form_builder = CustomFormBuilder