module SelectHelper
  def select_tag(name, option_tags = nil, options = {})
    option_tags = blank_option_tags(options.delete(:include_blank), options.delete(:prompt)) + option_tags
    super
  end

  def blank_option_tags(blank, prompt)
    case
      when blank == true then content_tag(:option, :value =>  '')
      when String === blank then content_tag(:option, blank, :value => '')
      when Array === blank then content_tag(:option, blank.first, :value => blank.last)
      when prompt then content_tag(:option, prompt)
    end || ''
  end
  
  def option_groups_for_select(container, selected = nil)
    option_groups_from_collection_for_select(container, :last, :first, :last, :first, selected)
  end

  # Generates a SELECT tag with option groups.
  # Groups structure is: [[grplabel, [optlabel, opt]], ...]
  def group_select(object, method, groups, options = {}, html_options = {})
    ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_group_select_tag(groups, options, html_options)
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
    concat "<table class='form-layout'>"
    yield
    concat '</table>'
  end
end

class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def line_for(property, title, content, options = {})
    label = label(property, title + ':')
    @template.line(label, content, options)
  end

  def group_select(method, choices, options = {}, html_options = {})
    @template.group_select(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
  end
end	

ActionView::Base.default_form_builder = CustomFormBuilder