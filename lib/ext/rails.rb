class ActiveRecord::Base
  def self.property(*args)
  end
end

class ActionController::Base
  def render_partial(partial, locals = {})
    render :partial => partial, :locals => locals
  end  
end

class ActionView::Base
  def bench(title, &block)
    benchmark("Outputted #{title}", :level => :debug, &block)
  end
end

module ActionView::Helpers::FormOptionsHelper
  def grouped_select(object, method, groups, options = {}, html_options = {})
    ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_grouped_select_tag(groups, options, html_options)
  end
end

class ActionView::Helpers::InstanceTag
  def to_grouped_select_tag(groups, options, html_options)
    html_options = html_options.stringify_keys
    add_default_name_and_id(html_options)
    value = value(object)
    selected_value = options.has_key?(:selected) ? options[:selected] : value
    content_tag("select", add_options(@template_object.grouped_options_for_select(groups, selected_value), options, selected_value), html_options)
  end
end

class ActionView::Helpers::FormBuilder
  def grouped_select(method, choices, options = {}, html_options = {})
    @template.grouped_select(@object_name, method, choices, objectify_options(options), @default_options.merge(html_options))
  end
end
