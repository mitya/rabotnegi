class TestController < ApplicationController
  layout false
  
  def foo
  end
  
  def error
    raise ArgumentError, "You requested an error!"
  end

  def dev
    render "test/#{params[:template]}", layout: false
  end
  
  def styles
    render "test/styles", layout: false
  end
  
  def lorem
    @count = params[:count].to_i
    render "test/lorem", layout: false
  end  
end
