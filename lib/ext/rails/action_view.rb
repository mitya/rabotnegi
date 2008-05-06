class ActionView::Base
  def render_part(partial, locals = {})
    controller.render_part(partial, locals)
  end
end

module ActionView::Helpers
  module FormTagHelper
    def label_tag(target, title, options = {})
  	  content_tag :label, title + ':', { "for" => target }.update(options.stringify_keys)
  	end
    
    def single_select_tag(name, choices, selected_value, options = {})
      option_tags = blank_option_tags(options) + options_for_select(choices, selected_value)
      content_tag :select, option_tags, { "name" => name, "id" => name }.update(options.stringify_keys)
    end
    
    def group_select_tag(name, choices, selected_value, options = {})
      option_tags = blank_option_tags(options) + option_groups_from_collection_for_select(choices, :last, :first, :last, :first, selected_value)
      content_tag :select, option_tags, { "name" => name, "id" => name }.update(options.stringify_keys)
    end
    
    alias original_select_tag select_tag
    def select_tag(name, choices, *args)
      if choices.is_a? String
        original_select_tag(name, choices, *args)
      elsif choices.first.last.is_a?(Array)
        group_select_tag(name, choices, *args)
      else
        single_select_tag(name, choices, *args)
      end
    end
    
  private
    def blank_option_tags(options = {})
      blank = options[:blank]
      prompt = options[:prompt]
      
      option_tags = ''
      option_tags << content_tag(:option) if blank == true
      option_tags << content_tag(:option, blank) if blank.is_a? String
      option_tags << content_tag(:option, blank.first, :value => blank.last) if blank.is_a? Array
      option_tags << content_tag(:option, prompt) if prompt
      option_tags
    end
  end
  
  module FormOptionsHelper
    # Generates <select> tag with option groups
    # groups is [[grplabel, [optlabel, opt]], ...]
    def group_select(object, property, groups, options = {})
      InstanceTag.new(object, property, self, nil, options.delete(:object)).to_group_select_tag(groups, options)
    end
    
    alias single_select select
    def select(object, method, choices, options = {}, html_options = {})
      choices.first.last.is_a?(Array) ?
        group_select(object, method, choices, options) :
        single_select(object, method, choices, options, html_options)
    end
  end
  
  module FormHelper
    
    # Like #form_for, but generate layout table inside
    def form(record_or_name_or_array, *args, &proc)
      raise ArgumentError, "Missing block" unless block_given?

      options = args.extract_options!
      options[:builder] = CustomFormBuilder

      case record_or_name_or_array
      when String, Symbol
        object_name = record_or_name_or_array
      when Array
        object = record_or_name_or_array.last
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        apply_form_for_options!(record_or_name_or_array, options)
        args.unshift object
      else
        object = record_or_name_or_array
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        apply_form_for_options!([object], options)
        args.unshift object
      end

      concat(form_tag(options.delete(:url) || {}, options.delete(:html) || {}), proc.binding)
  	  concat("<table class='form-layout'>", proc.binding)
      fields_for(object_name, *(args << options), &proc)
  	  concat('</table>', proc.binding)
      concat('</form>', proc.binding)
    end
  end
  
  class FormBuilder
  end

  class InstanceTag
    def to_group_select_tag(groups, options)
      rails_options, html_options = options.split(:selected, :include_blank, :prompt, :object)
      html_options.stringify_keys!
      add_default_name_and_id(html_options)
      value = value(object)
      selected_value = rails_options.has_key?(:selected) ? rails_options[:selected] : value
      inner_html = option_groups_from_collection_for_select(groups, :last, :first, :last, :first, selected_value)
      content_tag("select", add_options(inner_html, rails_options, selected_value), html_options)
    end
  end
end