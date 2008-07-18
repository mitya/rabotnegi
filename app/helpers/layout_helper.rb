module LayoutHelper
  def title(value)
    @page_title = value
  end
  
	def page_title
		@page_title || 'Работнеги.ру'
	end

  def identifier(value)
    @page_id = value
  end
	
	def page_id
	  "id='#{@page_id}'" if @page_id
	end  
end