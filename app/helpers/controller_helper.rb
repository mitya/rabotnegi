# coding: utf-8

module ControllerHelper
  OrderParam = :sort
  
  def employer_home_path
    current_employer ? employer_vacancies_path : employer_root_path
  end

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

  RoutePrefixes = Set.new([:edit, :edit_admin, :admin])

  def url(route_name, *args)
    route_name = "#{route_name}_#{args.first.class.model_name.singular}" if RoutePrefixes.include?(route_name)
    
    case route_name.to_s
    when "vacancy" then "/vacancies/#{args.first.id}"
    else send("#{route_name}_path", *args)
    end
  end
end
