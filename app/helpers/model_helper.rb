module ModelHelper
  def industry_groups
    @@for_select_with_groups ||= [
      ['Популярные', Industry.popular.map { |industry| [industry.name, industry.code.to_s] }],
      ['Остальные', Industry.other.map { |industry| [industry.name, industry.code.to_s] }]
    ]
  end

  def cities
    @@cities ||= City.all.map { |city| [city.name, city.code.to_s] }
  end

  def salaries
    @@salaries ||= [
    	['до 10 000', -10000],
    	['до 20 000', -20000],
    	['до 30 000', -30000],
    	['до 40 000', -40000],
    	['до 50 000', -50000],
    	['от 10 000',  10000],
    	['от 20 000',  20000],
    	['от 30 000',  30000],
    	['от 40 000',  40000],
    	['от 50 000',  50000]
    ]
  end
end