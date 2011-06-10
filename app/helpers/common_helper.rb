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
  
  def xcycle(*values)
    @xcycle_counter ||= -1
    @xcycle_counter += 1
    values[@xcycle_counter.modulo(values.length)]
  end
  
  def web_id_for_record(record)
    return nil unless record
    [web_prefix_for_class(record.class), record.id].join("-")
  end
  
  def web_prefix_for_class(klass)
    case klass
      when Vacancy then "v"
      else ActiveModel::Naming.singular(record)
    end    
  end
  
  def web_id(*args)
    args.map { |x| x.respond_to?(:to_key) ? web_id_for_record(x) : x }.join("-")
  end
end
