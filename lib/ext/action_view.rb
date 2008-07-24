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
  def to_group_select_tag(groups, options)
    rails_options, html_options = options.partition_by(:selected, :include_blank, :prompt, :object)
    html_options.stringify_keys!
    add_default_name_and_id(html_options)
    value = value(object)
    selected_value = rails_options.has_key?(:selected) ? rails_options[:selected] : value
    inner_html = option_groups_from_collection_for_select(groups, :last, :first, :last, :first, selected_value)
    content_tag("select", add_options(inner_html, rails_options, selected_value), html_options)
  end
end