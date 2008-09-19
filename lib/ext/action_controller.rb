class ActionController::Base
  def template(template, options = {})
    template = template.to_s
    options.merge!((template.include?('/') ? :template : :action) => template)
    render options
  end

  def redirect(url)
    url = { :action => url.to_s } if Symbol === url && url != :back
    redirect_to url
  end

  def partial(partial, options = {})
    render_options, render_options[:locals] = options.partition_by(:layout, :object, :collection, :status, :spacer_template)
    render_options[:partial] = Symbol === partial ? partial.to_s : partial
    render render_options
  end
end
