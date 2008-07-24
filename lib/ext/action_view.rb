class ActionView::Base
  def partial(partial, options = {})
    controller.partial(partial, options)
  end

  def partial(partial, options = {})
    render_options, render_options[:locals] = options.partition_by(:layout, :object, :collection, :status, :spacer_template)
    render_options[:partial] = Symbol === partial ? partial.to_s : partial
    render render_options
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