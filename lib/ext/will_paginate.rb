module WillPaginate::Finder::ClassMethods
  # Extends result collection with #sort_field and #sort_direction methods if there are :order_by option.
  # Format for :order_by is "field" for asc sorting, and "-field" for desc.
  def paginate_with_sorting(*args, &block)
    options = args.extract_options!
    sort_string = options.delete(:order_by)
    options[:order] = sort_string_to_sql(sort_string) if sort_string.present?
    args << options

    results = paginate_without_sorting(*args, &block)

    if sort_string.present?
      fld, dir = sort_string_to_pair(sort_string)
      results.metaclass.send(:define_method, :sort_field) { fld }
      results.metaclass.send(:define_method, :sort_direction) { dir }
    end
    
    results
  end
  alias_method_chain :paginate, :sorting
  
private
  # Parses "name" or "-name" to [:name, :asc] or [:name, :desc]
  def sort_string_to_pair(sort)    
    if sort.first == '-'
    then [sort.from(1).to_sym, :desc]
    else [sort.to_sym, :asc] end
  end
  
  def sort_string_to_sql(sort)
    fld, dir = sort_string_to_pair(sort)
    "#{fld} #{dir.to_s.upcase}"
  end  
end
