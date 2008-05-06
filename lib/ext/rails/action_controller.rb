class ActionController::Base
  def render_part(partial, options = {})
    render_options, render_options[:locals] = options / [:layout, :object, :collection, :status, :spacer_template]
    render render_options + {:partial => partial.to_s}
  end
  
  def render_multiview(partial, locals = {})
    render_part partial, locals + {:layout => true}
  end
end