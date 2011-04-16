# coding: utf-8

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
    object.errors.each_pair do |attr, messages|
      message = translate("errors.#{object.class.name.tableize}.#{attr}", :default => messages.to_sentence)
      error_messages << content_tag(:li, message)

      # attr_name = translate("activerecord.attributes.#{object.class.name.underscore}.#{attr}")
      # error_messages << content_tag(:li, content_tag(:b, attr_name) + ' — ' + msg)
    end
    
    result = ''
    result << content_tag(:h2, header_message.html_safe)
    result << content_tag(:ul, error_messages.join.html_safe)
   
    content_tag :div, result.html_safe, :class => 'form-errors'
  end
  
  def vacancies_page_title
    if @vacancies
      city = City.get(params[:city])
      industry = Industry.get(params[:industry]) if params[:industry].present?
      query = params[:q]
      page = params[:page]
  
      content = "Вакансии — #{city.name}"
      content << " — #{industry.name}" if industry
      content << " — #{query}" if query
      content << ", стр. №#{page}" if page
      content
    else
      "Поиск вакансий"
    end
  end
  
  def resumes_page_title
    if @resumes
      city = City[params[:city]] if params[:city].present?
      industry = Industry[params[:industry]] if params[:industry].present?
      query = params[:q]
      page = params[:page]
    
      content = "Резюме — #{city.name}"
      content << " — #{industry.name}" if industry
      content << " — #{query}" if query
      content << ", стр. №#{page}" if page
      content
    else
      "Поиск резюме"
    end
  end
  
  def site_desc
    "Работнеги.ру — это сайт который позволяет быстро найти работу или работников. Простой в использовании и не требует регистрации."
  end
  
  def back_to_all_vacancies_url_for(vacancy)
    request.referer =~ /vacancies/ ? :back : vacancies_path(vacancy.city, vacancy.industry)
  end
end

ActionView::Base.field_error_proc = -> html_tag, instance do
  if html_tag =~ /<label/
    "<span class='invalid' title='#{instance.error_message}'>#{html_tag}</span>"
  else
    "<span class='invalid'>#{html_tag}</span>"
  end
end
