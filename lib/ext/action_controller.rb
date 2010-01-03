class ActionController::Base
  def render_partial(partial, locals = {})
    render :partial => partial, :locals => locals
  end  
end
