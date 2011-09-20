# coding: utf-8

require 'fileutils'
require 'net/http'
require 'time'

# Rabota.ru service URL:
#   JSON: http://www.rabota.ru/v3_jsonExport.html?wt=f&c=2&r=19&ot=t&cu=2&p=30&d=desc&cs=t&start=0&pp=50&fv=f&rc=992&new=1&t=1&country=1&c_rus=2&c_ukr=41&c_ec=133&sm=103
#   RSS: http://www.rabota.ru/v3_rssExport.html?wt=f&c=%d&r=%d&cu=2&p=30&d=desc&fv=f&rc=2123&new=1&t=1
# 
# Rabota.ru params:
#   w      - ключевые слова
#   ot (1) - только по названию
#   c      - город
#   sf     - salary
#   su     - salary unit (1 usd, 2 rub, 3 eur)
#   os     - график
#   ek     - excluded words
#   pp     - per page
#   p      - day count (1, 7 30)
# 
# Response data item sample:
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
# 
class RabotaRu::VacancyLoader
  JsonUrlTemplate = "/v3_jsonExport.html?wt=f&c={city}&r={industry}&ot=t&cu=2&p=30&d=desc&cs=t&start=0&pp=50&fv=f&rc=992&new=1&t=1&country=1&c_rus=2&c_ukr=41&c_ec=133&sm=103"
  
  def initialize(options = {})
    @vacancies = []
    @work_directory = "#{Rails.root}/tmp/rabotaru"
    @vacancy_converter = RabotaRu::VacancyConverter.new(self)
    @cities = options[:city] ? [ City[options[:city]] ] : City.all
    @industries = options[:industry] ? [ Industry[options[:industry]] ] : Industry.all
    @remote = options[:remote]
    @log = Mai::EventWriter.new(:RRL, mai.timestamp_string)
  end

  attr_accessor :log
  attr_accessor :remote
  attr_accessor :work_directory
  attr_accessor :vacancies
  attr_accessor :info

# main proc

  # Загружает новые вакансии с Работы.ру в базу. 
  def load    
    log.info :start

    log.run self, :load_to_files unless @remote == false
    log.run self, :convert
    log.run self, :remove_duplicates
    log.run self, :filter
    log.run self, :save
    
    log.info :finish
  end

# steps

  # Загружает RSS-ленты в файлы в tmp/rabotaru/:industry.rss.
  # Предварительно очищает рабочий каталог.
  def load_to_files
    FileUtils.rm_r(work_directory) if File.exists?(work_directory)
    Dir.mkdir(work_directory)
  
    @cities.each do |city|
      @industries.each do |industry|
        url = mai.interpolate(JsonUrlTemplate, city: city.external_id, industry: industry.external_id)
        json_data = mai.http_get('www.rabota.ru', url)
        mai.write_file("#{work_directory}/#{city.code}-#{industry.code}.json", json_data)
        log.add city.code, industry.code, response_size: json_data.size, env: {url: url}
        # log.info :load_to_files, city.code, industry.code, response_size: json_data.size, env: {url: url}
      end
    end
  end

  def convert
    log.add dir: work_directory, files_count: Dir["#{work_directory}/*.json"].count
    
    Dir["#{work_directory}/*.json"].each do |file|
      data = File.read(file).sub!(/;\s*$/, '')
      items = mai.decode_json(data)
      vacancies = items.map { |item| convert_item(item) }.compact
      @vacancies.concat(vacancies)
    end

    log.end total: @vacancies.size
  end

  def convert_item(item)
    @vacancy_converter.convert(item)
  rescue => e    
    log.warn :convert, "skip item", title: item['position'], reason: mai.format_error(e.message), env: {error: e}
    nil
  end

  def remove_duplicates
    @vacancies.uniq_by! { |v| v.external_id }
    log.end left: @vacancies.size
  end
  
  def filter
    new_vacancies, updated_vacancies = [], []
    loaded_external_ids = @vacancies.map(&:external_id)
    existed_vacancies = Vacancy.any_in(external_id: loaded_external_ids)
    existed_vacancies_map = existed_vacancies.index_by(&:external_id)
    
    @vacancies.each do |loaded_vacancy|
      existed_vacancy = existed_vacancies_map[loaded_vacancy.external_id]
      if !existed_vacancy
        new_vacancies << loaded_vacancy
      elsif existed_vacancy.created_at != loaded_vacancy.created_at
        existed_vacancy.attributes = loaded_vacancy.attributes.except('_id')
        updated_vacancies << existed_vacancy
      else
        # vacancies are considered to be identical
      end
    end

    @vacancies = new_vacancies + updated_vacancies

    detalization = {}
    @vacancies.each { |v|
      detalization["#{v.city}-#{v.industry}"] ||= 0
      detalization["#{v.city}-#{v.industry}"] += 1
    }

    log.end new: new_vacancies.count, updated: updated_vacancies.count, total: @vacancies.count, env: detalization
  end

  def save
    @vacancies.each { |vacancy| vacancy.save! }
    log.end count: @vacancies.count
  end
end
