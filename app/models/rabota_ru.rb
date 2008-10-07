require 'fileutils'
require 'net/http'
require 'time'

# Rabota.ru params:
# w      - ключевые слова
# ot (1) - только по названию
# c      - город
# sf     - salary
# su     - salary unit (1 usd, 2 rub, 3 eur)
# os     - график
# ek     - excluded words
# pp     - per page
# p      - day count (1, 7 30)
# 
# Response item sample:
# {
#   "publishDate": "Fri, 19 Sep 2008 20:07:18 +0400",
#   "expireDate": "Fri, 26 Sep 2008 20:07:18 +0400",
#   "position": "Менеджер по персоналу (IT направление)",
#   "link": "http://www.rabota.ru/vacancy27047845.html",
#   "description": "Работодатель <a href=\"http://www.rabota.ru/agency15440.html\" target=\"_blank\">Spbnews</a> (Санкт-Петербург) предлагает вакансию на должность Менеджер по персоналу (IT направление). Зарплата <b>1173 - 1521</b> USD. Опыт работы до 2 лет. Образование неполное высшее. Вакансия опубликована cегодня, 20:07.<br/><strong>Требования:</strong><br /><br /><strong>Требования:</strong>\r\nМужчина\\Женщина.\r\nВозраст от 22 до 35\r\nОбязательно: опыт работы в подборе персонала от 1 года&sbquo; опыт\r\n поиска специалистов из IT сферы.\r\nЖелательно: знания в других направлений в управлени персоналом\r\n (КДП&sbquo; мотивация&sbquo; обучение).<br /><br /><strong>Обязанности:</strong><br /><br />В компанию по созданию Интернет проектов (штат 30 человек) требуется менеджер по подбору персонала.\r\n<strong>Обязанности:</strong>\r\n * Поиск и подбор персонала ( IT технологии).\r\n * Разработка систем мотивации.\r\n * Планирование обучения.<br /><br /><strong>Условия:</strong><br /><br /><strong>Условия:</strong>\r\n * Молодой коллектив\r\n * Офис - рядом со ст.м. Петроградская.\r\n * Оклад - от 27000 рублей.", 
#   "rubric_0": {"id": "14", "value": "Секретариат, делопроизводство, АХО"}, 
#   "rubric_1": {"id": "19", "value": "IT, компьютеры, работа в интернете"}, 
#   "rubric_2": {"id": "12", "value": "Кадровые службы, HR"}, 
#   "city": {"id": "2", "value": "Санкт-Петербург"}, 
#   "schedule": {"id": "1", "value": "полный рабочий день"}, 
#   "education": {"id": "3", "value": "неполное высшее"}, 
#   "experience": {"id": "2", "value": "до 2 лет"}, 
#   "employer": {"id": "15440", "value": "Spbnews", "link": "http://www.rabota.ru/agency15440.html"}, 
#   "salary": {"min": "27000", "max": "35000", "currency": {"value": "руб", "id": "2"}}, 
#   "responsibility": {"value": "<strong>Требования:</strong><br /><br /><strong>Требования:</strong>\r\nМужчина\\Женщина.\r\nВозраст от 22 до 35\r\nОбязательно: опыт работы в подборе персонала от 1 года&sbquo; опыт\r\n поиска специалистов из IT сферы.\r\nЖелательно: знания в других направлений в управлени персоналом\r\n (КДП&sbquo; мотивация&sbquo; обучение).<br /><br /><strong>Обязанности:</strong><br /><br />В компанию по созданию Интернет проектов (штат 30 человек) требуется менеджер по подбору персонала.\r\n<strong>Обязанности:</strong>\r\n * Поиск и подбор персонала ( IT технологии).\r\n * Разработка систем мотивации.\r\n * Планирование обучения.<br /><br /><strong>Условия:</strong><br /><br /><strong>Условия:</strong>\r\n * Молодой коллектив\r\n * Офис - рядом со ст.м. Петроградская.\r\n * Оклад - от 27000 рублей."}
# }
module RabotaRu
  mattr_accessor :logger
  self.logger = Logger.new("#{Rails.root}/log/loader_#{Rails.env}.log", Logger::DEBUG)
  def logger.format_message(severity, timestamp, progname, msg)
    "#{timestamp.xmlschema} #{msg}\n"
  end
  
  def self.load
    VacancyLoader.new.load
  end
  
  # Загружает вакансии с Работы.ру. 
  class VacancyLoader
    RssUrlTemplate = '/v3_rssExport.html?wt=f&c=%d&r=%d&cu=2&p=30&d=desc&fv=f&rc=2123&new=1&t=1'
    JsonUrlTemplate = '/v3_jsonExport.html?wt=f&c=%d&r=%d&cu=1&p=7&d=desc&start=180&pp=20&fv=f&rc=1687&new=1&t=1'
    
    attr_writer :skip_remote_loading
    def skip_remote_loading?() @skip_remote_loading end
      
    attr_accessor :work_directory
  
    def initialize
      @loaded_vacancies = []
      @work_directory = "#{Rails.root}/tmp/rabotaru"
      @vacancy_converter = VacancyConverter.new
    end
  
    # Загружает новые вакансии с Работы.ру в базу. 
    def load
      log "Начинается загрузка..."
      @loading = VacancyLoading.new :started_at => Time.current

      load_to_files unless @skip_remote_loading
      convert
      remove_duplicates
      filter
      save
      Rails.logger.flush
    end

  private
    # Загружает RSS-ленты в файлы в tmp/rabotaru/:industry.rss.
    # Предварительно очищает рабочий каталог.
    def load_to_files
      FileUtils.rm_r work_directory if File.exists? work_directory
      Dir.mkdir work_directory
    
      City.each do |city|
        Industry.each do |industry|
          log "Загрузка #{city.code}/#{industry.code}..."
          json_text = Net::HTTP.get 'www.rabota.ru',  JsonUrlTemplate % [city.external_id, industry.external_id]
          File.open("#{work_directory}/#{city.code}-#{industry.code}.json", 'w') { |file| file << json_text }
        end
      end    
    end
  
    # Конвертирует загруженные файлы в объекты и помещает результат в @loaded_vacancies.
    def convert
      Dir["#{work_directory}/*.json"].each do |file|
        items = JSON.parse(File.read(file).sub!(/;\s*$/, ''))
        log "Конверсия #{File.basename(file)} (#{items.size})..."
        items.each { |item| convert_item(item) }
      end    
      log "Загружено #{@loaded_vacancies.size} вакансий."
    end
    
    def convert_item(item)
      @loaded_vacancies << @vacancy_converter.convert(item)
    rescue => e
      log "Пропущена вакансия '#{item['position']}', так как #{e.class}: #{e.message} [#{e.backtrace.first(4).join(', ')}]."
    end
  
    def remove_duplicates
      @loaded_vacancies.uniq!
      log "После устранения дубликатов осталось #{@loaded_vacancies.size} вакансий."
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
      @loading.new_count = new_vacancies.size
      @loading.updated_count = updated_vacancies.size      
      @loading.details = {}
      @loaded_vacancies.each { |v|
        @loading.details[v.city] ||= {}
        @loading.details[v.city][v.industry] ||= 0
        @loading.details[v.city][v.industry] += 1
      }
      log "После фильтрации осталось #{@loaded_vacancies.size} вакансий."
    end
  
    # Сохраняет загруженные вакансии в базе.
    def save
      Vacancy.transaction {
        @loaded_vacancies.each(&:save)
        @loading.finished_at = Time.current
        @loading.save!
      }
    end
  
    def log(message)
      RabotaRu.logger.info message
      puts message if $0 =~ /rake|runner/
    end
  end
  
  class VacancyLoading < ActiveRecord::Base
    serialize :details
  end


  # Converts RSS items with vacancy XML to vacancy objects.
  class VacancyConverter
    def convert(hash)
      vacancy = Vacancy.new
      vacancy.title         = hash['position']
      vacancy.description   = hash['responsibility']['value']
      vacancy.external_id   = extract_id(hash['link'])
      vacancy.employer_name = hash['employer'] && hash['employer']['value']
      vacancy.city          = City.find_by_external_id(hash['city']['id']).to_s
      vacancy.industry      = Industry.find_by_external_ids(
        hash['rubric_0'] && hash['rubric_0']['id'], 
        hash['rubric_1'] && hash['rubric_1']['id'], 
        hash['rubric_2'] && hash['rubric_2']['id']).to_s
      vacancy.salary        = convert_salary(hash['salary'])
      vacancy.created_at    = Time.parse(hash['publishDate'])
      vacancy
    end

  private
    def get(hash, *keys)
      result = hash
      keys.each do |key|
        hash[key.to_s]
      end
    end
    
    # http://www.rabota.ru/vacancy1234567.html' => 1234567
    def extract_id(link)
      %r{http://www.rabota.ru/vacancy(\d+).html} =~ link
      $1.to_i
    end
  
    # {"min": "27000", "max": "35000", "currency": {"value": "руб", "id": "2"}}
    # {"min": "10000, "max": "10000", "currency": {"value": "руб", "id": "2"}}
    # {"min": "27000", "currency": {"value": "руб", "id": "2"}}
    # {"agreed":"yes"}
    def convert_salary(hash)
      salary = Salary.new
      if hash['agreed'] == 'yes'
        salary.negotiable = true
      else
        salary.negotiable = false
        case 
          when hash['min'] == hash['max']
            salary.exact = hash['min'].to_i
          when hash['max'].blank?
            salary.min = hash['min'].to_i
          when hash['min'].blank?
            salary.max = hash['max'].to_i
          else
            salary.min = hash['min'].to_i
            salary.max = hash['max'].to_i
        end
        salary.currency = convert_currency(hash['currency'])
        salary.convert_currency(:rub)
      end
      salary
    end
  
    # {"value": "руб", "id": "2"}
    def convert_currency(hash)
      case hash['value'].downcase
        when 'руб': :rub
        when 'usd': :usd
        when 'eur': :eur
        else
          Rails.logger.warn('Неизвестная валюта #{currency_string}')
          :rub
      end
    end
  end
end
