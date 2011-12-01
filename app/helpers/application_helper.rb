module ApplicationHelper
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
  
  # Fast cycling helper
  def xcycle(*values)
    @xcycle_counter ||= -1
    @xcycle_counter += 1
    values[@xcycle_counter.modulo(values.length)]
  end
  
  # (vacancy#1234) => "v-2134"
  def web_id_for_record(record)
    return nil unless record
    [web_prefix_for_class(record.class), record.id].join("-")
  end
  
  # (Vacancy) => "v"
  # (User) => "user"  
  def web_prefix_for_class(klass)
    case klass
      when Vacancy then "v"
      else ActiveModel::Naming.singular(record)
    end    
  end
  
  # (vacancy#1234) => "v-1234"
  # (:edit, vacancy#1234, :custom) => "edit-v-1234-custom"
  def web_id(*args)
    args.map { |x| x.respond_to?(:to_key) ? web_id_for_record(x) : x }.join("-")
  end

  # (wide: true, narrow: false, thin: true) => "wide thin"
  def classes_from(*args)
    return if args.first.nil?
    
    conditions = args.extract_options!
    static_classes = args.first
    classes = []
    classes << static_classes if static_classes.present?
    for klass, condition in conditions
      classes << klass if condition
    end
    classes.join(" ")
  end  
  
  # Works like content_tag. But:
  #   * :klass option can be used as :class
  #   * last argument is treated like a :class
  def element(*args, &block)
    options = args.extract_options!

    options[:class] = options.delete(:klass) if options.include?(:klass)
    options[:class] = args.pop if args.last.is_a?(String) && (args.length == 3 || args.length == 2 && block)
    
    args << options
    content_tag(*args, &block)
  end  
end
