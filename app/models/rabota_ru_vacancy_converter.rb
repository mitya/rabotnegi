# coding: utf-8

# Converts RSS items with vacancy XML to vacancy objects.
class RabotaRu::VacancyConverter
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
      when 'руб' then :rub
      when 'usd' then :usd
      when 'eur' then :eur
      else
        Rails.logger.warn('Неизвестная валюта #{currency_string}')
        :rub
    end
  end
end
