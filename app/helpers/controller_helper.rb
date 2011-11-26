module ControllerHelper
  OrderParam = :sort
  
  # generates a sort parameter like "date" or "-date"
  # reverses (adds a "-") when the pararmeter is already used for sorting
  def encode_order(field, reverse_by_default = false, param = params[OrderParam])
    param.blank??
      reverse_by_default ? "-#{field}" : field.to_s :
      param == field.to_s ?
        "-#{field}" :
        field.to_s
  end
  
  # "date"  => [:date, false]
  # "-date" => [:date, true]
  def decode_order(param = params[OrderParam])
    param.present??
      param.starts_with?('-') ? 
        [param.from(1), true] : 
        [param, false] :
      [nil, false]
  end  

  # "date"  => "date asc"
  # "-date" => "date desc"
  def decode_order_to_expr(param = params[OrderParam])
    field, reverse = decode_order(param)
    field.nil??
      nil :
      "#{field} #{reverse_to_symbol(reverse)}"
  end

  # "date"  => ["date", Mongo::ASCENDING]
  # "-date" => ["date", Mongo::DESCENDING]
  def decode_order_for_mongo(param = params[OrderParam])
    field, reverse = decode_order(param)
    [[field, reverse ? Mongo::DESCENDING : Mongo::ASCENDING]]
  end
  
  def reverse_to_symbol(reverse)
    reverse ? :desc : :asc
  end
  
  def order_class(field)
    current_field, reverse = decode_order
    field.to_s == current_field ? "sorted" : ""
  end  

  def quick_route(*args)
    case when args.first == :vacancy then "/vacancies/#{args.second.slug}"
      when args.first.is?(Vacancy) then "/vacancies/#{args.first.slug}"
      else nil
    end
  end

  def absolute_url(*args)
    "#{request.scheme}://#{request.host_with_port}#{url(*args)}"
  end

  def url(*args)
    quick_route(*args) || 
      (args.first.is?(Symbol, Mongoid::Document) && args.second.is?(Mongoid::Document) ? polymorphic_path(args) : send("#{args.shift}_path", *args))
  end
end
