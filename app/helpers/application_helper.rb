module ApplicationHelper
  include FormLayoutHelper
  
  def submit_section(label)
    %{<div class='submit'>
        <input type="submit" class='action-button' value='#{ label }'>
        <span class='cancel'>
          или
          <a href='#{ request.headers['Referer'] }' class='ui'>Отменить</a>
        <span>
      </div>}
  end
  
  def blank_option(label = '', value = '')
    content_tag :option, label, :value => value
  end
  
  def errors_for(object, options = {})
    I18n.with_options :scope => [:active_record, :error] do |locale|
      header_message = options.delete(:header_message) || locale.t(:default_header)
      error_messages = []
      object.errors.each do |attr, msg|
        attr_name = I18n.translate("active_record.human_attribute_names.#{object.class.name.underscore}.#{attr}")
        error_messages << content_tag(:li, content_tag(:b, attr_name) + ' — ' + msg)
      end
      
      result = ''
      result << content_tag(:h2, header_message)
      result << content_tag(:ul, error_messages)
     
      content_tag(:div, result, :class => 'form-errors')
    end
  end
end

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  if html_tag =~ /<label/
    "<span class='invalid' title='#{instance.error_message}'>#{html_tag}</span>"
  else
    "<span class='invalid'>#{html_tag}</span>"
  end
end