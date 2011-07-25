# coding: utf-8

module ApplicationHelper
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
  
  def classes_from(*args)
    conditions = args.extract_options!
    static_classes = args.first
    classes = []
    classes << static_classes if static_classes.present?
    for klass, condition in conditions
      classes << klass if condition
    end
    classes.join(" ")
  end  
  
  def tg(*args, &block)
    options = args.extract_options!

    options[:class] = options.delete(:klass) if options.include?(:klass)
    options[:class] = args.pop if args.last.is_a?(String) && (args.length == 3 || args.length == 2 && block)
    
    args << options
    content_tag(*args, &block)
  end
end
