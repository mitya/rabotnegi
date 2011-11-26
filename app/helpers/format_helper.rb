module FormatHelper
  def format_hash_as_lines(hash)
    hash.map { |key, val| "#{key}: #{val}" }.join("\n")
  end
  
  def format_hash_as_dl(hash)
    return content_tag(:p, "—") if hash.blank?
    
    content_tag :dl do
      hash.map { |key, val| content_tag(:dt, key) + content_tag(:dd, val) }.join.html_safe
    end
  end

  def inspect_hash(hash)
    content_tag :table, :class => "hash" do
      hash.map do |key, value|
        content_tag(:tr) do
          content_tag(:th, key.to_s.humanize) + content_tag(:td, value)
        end        
      end.join.html_safe
    end
  end
  
  def inspect_array(array)
    content_tag :ul, :class => "array" do
      array.map do |item|
        content_tag(:li, item.to_s)
      end.join.html_safe
    end    
  end

  def inspect_array_inline(array)
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
  
  def format_date_time(time)
    time.localtime.to_s(:rus_zone)
  end

  def number(value)
    number_with_delimiter(value)
  end
  
  def format_data(data)
    case data
      when Time then format_date_time(data)
      when Integer then number(data)
      else data
    end
  end
  
  alias f format_data

  def reflect_data(model, field, options = {})
    value = model.send(field.name)

    return "—" if value.blank?

    content = case value
      when Time then value.localtime.to_s(:short_date)
      when Integer then number(value)
      when BSON::ObjectId
        options[:truncate] == false ? value : "#{value.to_s.first(8)}...#{value.to_s.last(4)}"
      when String
        value = truncate(value, length: 60, separator: ' ') unless options[:truncate] == false
        raw(value)
      else value
    end
    
    case field.format
      when :link then link_to(content, url(:admin_item, field.klass.key, model))
      when :city then City[content]
      when :industry then Industry[content]
      when :pre then content_tag(:pre, content)
      when String then send(field.format, content)
      else content
    end
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
end
