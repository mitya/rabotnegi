class ActionController::Base
  def render_part(partial, options = {})
    render_options, render_options[:locals] = options / [:layout, :object, :collection, :status, :spacer_template]
    render render_options + {:partial => partial.to_s}
  end
  
  def render_multiview(partial, locals = {})
    render_part partial, locals + {:layout => true}
  end
  
  def template(template, options = {})
    render options.merge(:action => template.to_s)
  end
  
  def redirect(url)
    return redirect_to(:back) if url == :back
    redirect_to url.is_a?(Symbol) ? {:action => url} : url
  end
  
  def partial(partial, options = {})
    render_options, render_options[:locals] = options / [:layout, :object, :collection, :status, :spacer_template]
    render_options[:partial] = partial.is_a?(Symbol) ? partial.to_s : partial
    render render_options
  end  
end