module LayoutHelper
  include ActionMailer::AdvAttrAccessor
  adv_attr_accessor :title, :identifier, :desc, :keywords
  
	def page_title
		title ? "#{title} @ Работнеги.ру" : 'Работнеги.ру'
	end

	def page_id
	  "id='#{identifier}'" if identifier
	end  
end
