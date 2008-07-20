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
      log "Начинается загрузка..."
    
      load_to_files unless @skip_remote_loading
      convert
      remove_duplicates
      filter
      save
    end

  private
    # Загружает RSS-ленты в файлы в tmp/rabotaru/:industry.rss.
    # Предварительно очищает рабочий каталог.
    def load_to_files
      FileUtils.rm_r(work_directory) if File.exists?(work_directory)
      Dir.mkdir(work_directory)
    
      City.each do |city|
        Industry.each do |industry|
          rss_text = Net::HTTP.get('www.rabota.ru', '/v3_rssExport.html?c=%d&r=%d' % [city.external_id, industry.external_id])
          File.write("#{work_directory}/#{city.code}-#{industry.code}.rss", rss_text)
        end
      end    
    end
  
    # Конвертирует загруженные файлы в объекты и помещает результат в @loaded_vacancies.
    def convert
      Dir["#{work_directory}/*.rss"].each do |rss_file|
        rss_hash = read_rss_file_to_hash(rss_file)
        
        log "Конверсия '#{File.basename(rss_file, '.rss')} (#{rss_hash['channel']['item'].length})'..." 
      
        rss_hash['channel']['item'].each do |rss_item|
          begin
            vacancy = @vacancy_converter.convert(rss_item)
            @loaded_vacancies << vacancy
          rescue => e
            log "Пропущена вакансия '#{rss_item['title']}', так как #{e.class} '#{e.message}'."
          end
        end        
      end
    
      log "Загружено #{@loaded_vacancies.size} вакансий."
    end
  
    def remove_duplicates
      @loaded_vacancies.uniq!
      log "После устранения дубликатов осталось #{@loaded_vacancies.count} вакансий."
    end
  
    # Фильтрует сисок вакансий в @loaded_vacancies, остовляет только новые и обновленные вакансии.
    def filter
      loaded_external_ids = @loaded_vacancies.map(&:external_id)
      existed_vacancies = Vacancy.find_all_by_external_id(loaded_external_ids)
      existed_vacancies_map = existed_vacancies.index_by(&:external_id)
    
      new_vacancies, updated_vacancies = [], []
      @loaded_vacancies.each do |loaded_vacancy|
        existed_vacancy = existed_vacancies_map[loaded_vacancy.external_id]
        if not existed_vacancy
          new_vacancies << loaded_vacancy
        elsif existed_vacancy.created_at != loaded_vacancy.created_at
          existed_vacancy.attributes = loaded_vacancy.attributes
          updated_vacancies << existed_vacancy
        end
      end
    
      @loaded_vacancies = new_vacancies + updated_vacancies
      log "После фильтрации осталось #{@loaded_vacancies.count} вакансий."
    end
  
    # Сохраняет загруженные вакансии в базе.
    def save
      Vacancy.transaction do
        @loaded_vacancies.each(&:save)
      end
    end
  
    def work_directory
      "#{Rails.root}/tmp/rabotaru"
    end

    def read_rss_file_to_hash(rss_file)
      rss_text = File.read(rss_file)
      returning XmlSimple.xml_in(rss_text, 'forcearray' => false) do |rss_hash|
        rss_hash['channel']['item'] = [rss_hash['channel']['item']] if rss_hash['channel']['item'].is_a?(Hash)
        rss_hash['channel']['item'] = [] if !rss_hash['channel']['item']
      end
    end

    def log(message)
      Rails.logger.debug("VacancyLoader: #{message}")
    end
  end


  # Converts RSS items with vacancy XML to vacancy objects.
  class VacancyConverter
    def convert(rss_item)
      vacancy = Vacancy.new
      vacancy.title = rss_item['position']
      vacancy.description = format_description(rss_item['description'], rss_item['responsibility'])
      vacancy.external_id = extract_id(rss_item['guid'])
      vacancy.employer_name = rss_item['employer']['content']
      vacancy.city = City.find_by_external_id(rss_item['city']['vacancy:number']).to_s
      vacancy.industry = Industry.find_by_external_id(rss_item['rubric_0']['vacancy:number']).to_s
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