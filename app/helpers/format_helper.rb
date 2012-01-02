module FormatHelper
  def hash_as_lines(hash)
    hash.map { |key, val| "#{key}: #{val}" }.join("\n")
  end
  
  def hash_as_dl(hash)
    return element(:p, "—") if hash.blank?
    
    element :dl do
      hash.map { |key, val| element(:dt, key) + element(:dd, val) }.join.html_safe
    end
  end

  def hash_view(hash)
    return "" if hash.blank?
    element :table, "hash" do
      hash.map do |key, value|
        element(:tr) do
          element(:th, key.to_s.titleize) + element(:td, value)
        end        
      end.join.html_safe
    end
  end
  
  def array_view(array)
    element :ul, "array" do
      array.map do |item|
        element(:li, item.to_s)
      end.join.html_safe
    end    
  end

  def array_inline(array)
    array.join(" — ") if array
  end

  def time(seconds)
    min = seconds.to_i / 60
    sec = seconds.to_i - min * 60
    "%02i:%02i" % [min, sec]
  end

  # 05:200
  # 02:30:200  
  def sec_usec(seconds)
    "%.3f" % [seconds] if seconds
  end
  
  def datetime(time)
    time.localtime.to_s(:rus_zone)
  end

  def number(value)
    number_with_delimiter(value)
  end

  def limited_number(value, threshold)
    value < threshold ? value : content_tag(:span, value, :class => "extreme-number")
  end

  Colors = %w(000 666 8f4bcf 519618 8f0d0d 387aad ab882e 8f88cf 4a7558 3aa c400b7 00f e10c02 800000 808000 008000 000080 800080 F0F 408099 FF8000 008080)

  def color_code(item)
    @color_codes ||= {}
    @color_codes[item] ||= Colors[@color_codes.size.remainder(Colors.length)]
    color = @color_codes[item]
    content_tag :span, item, :class => "color", style: "background-color: ##{color}"
  end

  def html_string(value, options)
    if options[:truncate]
      max_length = options[:truncate].is_a?(Numeric) ? options[:truncate] : 60
      value = truncate(value, length: max_length, separator: ' ')
    end
    raw(value)  
  end

  def short_object_id(value)
    "#{value.to_s.first(8)}-#{value.to_s.last(4)}"
  end

  # options: compact, trim
  def inspect_value(value, options = {})
    return "" if value.blank?

    case value
      when Time then options[:compact] ? l(value.localtime, format: :short) : l(value.localtime)
      when Integer then number(value)
      when BSON::ObjectId then options[:compact] ? short_object_id(value) : value
      when String then html_string(value, options.slice(:trim))
      when Symbol then value.to_s.humanize
      else value
    end    
  end
  
  alias f inspect_value

  def inspect_field(model, field, options = {})
    value = model.send_chain(field.name) unless field.custom?
    value = short_object_id(value) if BSON::ObjectId === value

    result = case field.format
      when :link then link_to(value, url(:admin_item, field.collection.key, model))
      when :city then City.get(value)
      when :industry then Industry.get(value)
      when :pre then element(:pre, value)
      when String then send(field.format, value)
      when Proc then field.format.(model)
      else inspect_value(value, options)
    end
    
    result = result.to_s.truncate(field.trim) if field.trim    
    result
  end
end
