module ApplicationHelper
  include FormLayoutHelper
  
  def submit_section(label)
    %{<div class='submit'>
        <input type="submit" class='action-button' value='#{ label }'>
        <span class='cancel'>или <a href='#{ request.headers['Referer'] }' class='ui'>Отменить</a><span>
      </div>}
  end
  
  def blank_option(label = '', value = '')
    content_tag :option, label, :value => value
  end
  
  def errors_for(object, options = {})
    return '' if object.errors.empty?
    
    header_message = options.delete(:header_message) || translate("activerecord.errors.template.header")
    error_messages = []
    object.errors.each do |attr, msg|
      attr_name = translate("activerecord.attributes.#{object.class.name.underscore}.#{attr}")
      error_messages << content_tag(:li, content_tag(:b, attr_name) + ' — ' + msg)
    end
    
    result = ''
    result << content_tag(:h2, header_message)
    # result << content_tag(:ul, error_messages)
   
    content_tag :div, result, :class => 'form-errors'
  end
  
  def title_for_vacancies
		city = City[params[:city]]
		industry = Industry[params[:industry]] if params[:industry].present?
		query = params[:q]
		page = params[:p]
		
		content = "Вакансии — #{city.name}"
		content << " — #{industry.name}" if industry
		content << " — #{query}" if query
		content << ", стр. №#{page}" if page
		title content
  end
  
	def title_for_resumes
		city = City[params[:city]] if params[:city].present?
		industry = Industry[params[:industry]] if params[:industry].present?
		query = params[:q]
		page = params[:p]
		
		content = "Резюме — #{city.name}"
		content << " — #{industry.name}" if industry
		content << " — #{query}" if query
		content << ", стр. №#{page}" if page
		title content
	end
  
  def desc_for_site
    desc "Работнеги.ру — это сайт который позволяет быстро найти работу или работников. Простой в использовании и не требует регистрации."
  end
  
  def back_to_all_vacancies_url_for(vacancy)
    request.referer =~ /vacancies/ ? :back : nice_vacancies_path(:city => vacancy.city, :industry => vacancy.industry)
  end
end

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  if html_tag =~ /<label/
    "<span class='invalid' title='#{instance.error_message}'>#{html_tag}</span>"
  else
    "<span class='invalid'>#{html_tag}</span>"
  end
end