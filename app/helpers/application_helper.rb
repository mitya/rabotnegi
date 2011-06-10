# coding: utf-8

module ApplicationHelper
  include FormLayoutHelper
  
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

# ActionView::Base.field_error_proc = -> html_tag, instance do
#   if html_tag =~ /<label/
#     "<span class='invalid' title='#{instance.error_message}'>#{html_tag}</span>"
#   else
#     "<span class='invalid'>#{html_tag}</span>"
#   end
# end
