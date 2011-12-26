# Loads the vacancies feed into tmp/rabotaru-DATE/CITY-INDUSTRY.rss
class RabotaRu::VacancyLoader
  JsonUrlTemplate = "http://www.rabota.ru/v3_jsonExport.html?wt=f&c={city}&r={industry}&ot=t&cu=2&p=30&d=desc&cs=t&start=0&pp=50&fv=f&rc=992&new=1&t=1&country=1&c_rus=2&c_ukr=41&c_ec=133&sm=103"  

  attr_accessor :work_dir

  def initialize(options = {})
    @work_dir = Rails.root.join("tmp/rabotaru-#{my.date_stamp}")
    @cities = options[:city] ? City.get( options[:city] ) : City.all
    @industries = options[:industry] ? Industry.get( options[:industry] ) : Industry.all
  end

  def load
    create_work_dir
    @cities.product(@industries) { |city, industry| load_one(city, industry) }
  end

private

  def load_one(city, industry)
    url = gg.interpolate(JsonUrlTemplate, city: city.external_id, industry: industry.external_id)
    json = gg.http.get(url)
    gg.files.write("#{work_dir}/#{city.key}-#{industry.key}.json", json)
    gg.info 'feed loaded', [city, industry, json.size]
  end  
  
  def create_work_dir
    FileUtils.rm_r(@work_dir) if File.exists?(@work_dir)
    Dir.mkdir(@work_dir)    
  end
end
