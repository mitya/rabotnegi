module FormLayoutHelper
  def trb(label, content, options = {})
    options.assert_valid_keys(:required, :id, :before, :after, :comment, :class)
    label = [label]
    content = [content]
    
    row_id = options[:rid]
    row_id = row_id.join('_') if row_id.is_a?(Array)
    
    row_options = {}
    row_options[:id] = "#{row_id}_row" if row_id
    row_options[:class] = options[:class].present?? [options[:class]] : []
    row_options[:class] << "required" if options[:required]
    row_options[:class] << "high" if options[:high]
    row_options[:class] = row_options[:class].any?? row_options[:class].join(' ') : nil
        
    content.unshift options[:before] if options[:before]
    content.push content_tag(:span, '(обязательное поле)', :class => 'required-mark') if options[:required]
    content.push options[:after] if options[:after]
    content.push tag(:br) + content_tag(:small, options[:comment]) if options[:comment]

    content_tag :tr, row_options do
      content_tag(:th, label.join(' ')) +
      content_tag(:td, content.join(' ')) + 
      content_tag(:td, "", :class => "other")
    end
  end
  
  def trs(content, row_options = {})
    content_tag :tr, row_options do
      content_tag :td, content, :colspan => 2
    end
  end
  
  def tr1(first, options = {})
    trb(first, nil, options)
  end

  def tr2(last, options = {})
    trb(nil, last, options)
  end
  
  def tr(name, title, content, options = {})
    label = label_tag(name, title + ':')
    trb(label, content, options)
  end
    
  def section(options = {}, &block)
    concat tag(:tbody, options, true)
    yield
  end
  
  def wrapper(&block)
    concat "<table class='form-layout'>"
    yield
    concat '</table>'
  end
end

class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def tr(property, title, content, options = {})
    label = label(property, title + ':')
    @template.trb(label, content, options)
  end
end
