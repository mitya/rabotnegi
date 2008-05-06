require 'fileutils'
require 'net/http'
require 'time'

module RabotaRu
# Загружает вакансии с Работы.ру. 
class VacancyLoader
  attr_boolean :skip_remote_loading
  
  def initialize
    @loaded_vacancies = []
    @skip_remote_loading = false
    @vacancy_converter = VacancyConverter.new
  end
  
  # Загружает новые вакансии с Работы.ру в базу. 
  def load
    log_debug "Начинается загрузка..."
    
    load_to_files unless @skip_remote_loading
    convert
    remove_duplicates
    filter
    save
  end

private
  RABOTARU_HOST = 'www.rabota.ru'
  RABOTARU_PATH = '/v3_rssExport.html?c=%d&r=%d'

  def logger; ActionController::Base.logger end

  # Загружает RSS-ленты в файлы в tmp/rabotaru/:industry.rss.
  # Предварительно очищает рабочий каталог.
  def load_to_files
    FileUtils.rm_r(work_directory) if File.exists?(work_directory)
    Dir.mkdir(work_directory)
    
    $city_metadata_table.each do |city_code, city_external_id|
      $industry_metadata_table.each do |industry_code, industry_external_id|
        rss_text = Net::HTTP.get(RABOTARU_HOST, RABOTARU_PATH % [city_external_id, industry_external_id])
        rss_file = File.open("#{work_directory}/#{city_code}-#{industry_code}.rss", 'w')
        rss_file.write(rss_text)
        rss_file.close()
      end
    end
  end
  
  # Конвертирует загруженные файлы в объекты и помещает результат в @loaded_vacancies.
  def convert
    for rss_file in Dir["#{work_directory}/*.rss"] do
      rss_hash = convert_rss_file_to_rss_hash(rss_file)

      log_debug("Конверсия '#{File.basename(rssFile, '.rss')} (#{rssHash['channel']['item'].length})'..." )
      
      for rss_item in rss_hash['channel']['item'] do begin
        vacancy = @vacancy_converter.convert(rss_item)
        @loaded_vacancies << vacancy
      rescue
        log_debug("Пропущена вакансия '#{rssItem['title']}', так как #{$!.class} '#{$!.message}'.")
      end end
    end
    
    log_debug("Загружено #{@loaded_vacancies.size} вакансий.")
  end
  
  def remove_duplicates
    @loaded_vacancies.uniq!
    log_debug("После устранения дубликатов осталось #{@loaded_vacancies.count} вакансий.")
  end
  
  # Фильтрует сисок вакансий в @loaded_vacancies, остовляет только новые и обновленные вакансии.
  def filter
    loaded_external_ids = @loaded_vacancies.map(&:external_id)
    existed_vacancies = Vacancy.find(:all, :conditions => {:external_id => @loaded_vacancies.map(&:external_id)})
    existed_vacancies_map = existed_vacancies.index_by(&:external_id)
    
    new_vacancies = []
    updated_vacancies = []
    @loaded_vacancies.each do |loaded_vacancy|
      existed_vacancy = existed_vacancies_map[loaded_vacancy.external_id]
      if !existed_vacancy
        new_vacancies << loaded_vacancy
      elsif existed_vacancy.created_at != loaded_vacancy.created_at
        existed_vacancy.attributes = loaded_vacancy.attributes
        updated_vacancies << existed_vacancy
      end
    end
    
    @loaded_vacancies = new_vacancies + updated_vacancies
    log_debug "После фильтрации осталось #{@loaded_vacancies.count} вакансий."
  end
  
  # Сохраняет загруженные вакансии в базе.
  def save; @loaded_vacancies.each(&:save) end
  
  def work_directory; "#{RAILS_ROOT}/tmp/rabotaru" end

  def convert_rss_file_to_rss_hash(rss_file)
    rss_text = IO.read(rss_file)
    rss_hash = XmlSimple.xml_in(rss_text, 'forcearray' => false)
    rss_hash['channel']['item'] = [rss_hash['channel']['item']] if rss_hash['channel']['item'].is_a?(Hash)
    rss_hash['channel']['item'] = [] if !rss_hash['channel']['item']
    rss_hash
  end

  def log_debug(message) logger.debug("VacancyLoader: #{message}") end
end

# Converts RSS items with vacancy XML to vacancy objects.
class RabotaRu::VacancyConverter
  def convert(rss_item)
    vacancy = Vacancy.new
    vacancy.title = rss_item['position']
    vacancy.description = format_description(rss_item['description'], rss_item['responsibility'])
    vacancy.external_id = extract_id(rss_item['guid'])
    vacancy.employer_name = rss_item['employer']['content']
    vacancy.city = find_city(rss_item['city']['vacancy:number'].to_i)
    vacancy.industry = find_industry(rss_item['rubric_0']['vacancy:number'].to_i)
    vacancy.salary = convert_salary(rss_item['salary'])
    vacancy.created_at = Time.parse(rss_item['date']['vacancy:publishDate'])
    vacancy
  end
  
private
  def format_description(description, responsibility)
    description
  end
  
  # Extracts external vacancy ID from link like 'http://www.rabota.ru/vacancy1234567.html'
  def extract_id(external_vacancy_link)
    %r{http://www.rabota.ru/vacancy(\d+).html} =~ external_vacancy_link
    $1.to_i
  end
  
  # Finds city code by extenal ID
  def find_city(eid)
    $city_metadata_table.find { |code, ext_id| ext_id == eid }[0] rescue raise ArgumentError, "Город ##{eid} не найден"
  end
  
  # Находит отрасль по внешнему номеру.
  def find_industry(eid)
    $industry_metadata_table.find { |code, ext_id| ext_id == eid }[0] rescue raise ArgumentError, "Отрасль ##{eid} не найден"
  end
  
  # Конвертирует XML зарплаты в объект Salary.
  # Обрабатываемые ситуации:
  #   <vacancy:salary vacancy:min="1000" vacancy:max="2000" vacancy:currency="USD"/>
  #   <vacancy:salary vacancy:min="1000" vacancy:max="1000" vacancy:currency="руб"/>
  #   <vacancy:salary vacancy:min="1000" vacancy:max="" vacancy:currency="USD"/>
  #   <vacancy:salary vacancy:min="" vacancy:max="1000" vacancy:currency="USD"/>
  #   <vacancy:salary vacancy:agreed="yes"/>
  def convert_salary(salary_xml)
    salary = Salary.new
    
    if salary_xml['vacancy:agreed'] == 'yes'
      salary.negotiable = true
      return salary 
    end
    
    salary.negotiable = false
    if salary_xml['vacancy:min'] == salary_xml['vacancy:max']
      salary.exact = salary_xml['vacancy:min'].to_i
    elsif salary_xml['vacancy:max'] == ''
      salary.min = salary_xml['vacancy:min'].to_i
    elsif salary_xml['vacancy:min'] == ''
      salary.max = salary_xml['vacancy:max'].to_i
    else
      salary.min = salary_xml['vacancy:min'].to_i
      salary.max = salary_xml['vacancy:max'].to_i
    end

    salary.currency = convert_currency(salary_xml['vacancy:currency'])
    salary.convert_currency!(:rub)

    salary
  end
  
  def convert_currency(currency_string)
    raise_if_nil currency_string, :currency_string
    case currency_string.downcase
      when 'руб': :rub
      when 'usd': :usd
      when 'eur': :eur
      else; raise ArgumentError, "Неизвестная валюта #{currency_string}"
    end
  end
end
end