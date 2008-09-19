module FormLayoutHelper
  # Options: :required, :id, :before, :after, :comment
  def trb(label, content, options = {})
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

ActionView::Base.default_form_builder = CustomFormBuilder
