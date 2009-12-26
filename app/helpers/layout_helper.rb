module LayoutHelper
  include ActionMailer::AdvAttrAccessor
  adv_attr_accessor :title, :identifier, :desc, :keywords
  
  def title(*args)
    if args.empty?
      @title
    else
      @title = args.first
      @title_options = args.extract_options!
    end
  end
  
	def window_title
		title ? "#{title} - Работнеги.ру" : 'Работнеги.ру'
	end
	
	def page_title
	  @title_options[:page] ? @title : nil
	end
	
	def title_html
    content_tag :h1, title, :class => 'page_title'
	end

	def page_id
	  "id='#{identifier}'" if identifier
	end  
end
