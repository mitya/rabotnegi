class ActionView::Base
  def bench(title, &block)
    benchmark("Outputted #{title}", :level => :debug, &block)
  end
end

module ActionView::Helpers::FormOptionsHelper
  def option_groups_for_select(container, selected = nil)
    option_groups_from_collection_for_select(container, :last, :first, :last, :first, selected)
  end

  # Generates a SELECT tag with option groups.
  # Groups structure is: [[grplabel, [optlabel, opt]], ...]
  def group_select(object, method, groups, options = {}, html_options = {})
    ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_group_select_tag(groups, options, html_options)
  end
end

class ActionView::Helpers::InstanceTag
  def to_group_select_tag(groups, options, html_options)
    html_options = html_options.stringify_keys
    add_default_name_and_id(html_options)
    value = value(object)
    selected_value = options.has_key?(:selected) ? options[:selected] : value
    content_tag("select", add_options(@template_object.option_groups_for_select(groups, selected_value), options, selected_value), html_options)
  end
end

class ActionView::Helpers::FormBuilder
  def group_select(method, choices, options = {}, html_options = {})
    @template.group_select(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
  end
end
