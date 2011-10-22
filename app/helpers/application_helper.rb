# coding: utf-8

module ApplicationHelper
  def format_hash_as_lines(hash)
    hash.map { |key, val| "#{key}: #{val}" }.join("\n")
  end
  
  def format_hash_as_dl(hash)
    return content_tag(:p, "—") if hash.blank?
    
    content_tag :dl do
      hash.map { |key, val| content_tag(:dt, key) + content_tag(:dd, val) }.join.html_safe
    end
  end
end
