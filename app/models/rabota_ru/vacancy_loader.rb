# Loads the vacancies feed into tmp/rabotaru-DATE/CITY-INDUSTRY.rss
class RabotaRu::VacancyLoader
  JsonUrlTemplate = "http://www.rabota.ru/v3_jsonExport.html?wt=f&c={city}&r={industry}&ot=t&cu=2&p=30&d=desc&cs=t&start=0&pp=50&fv=f&rc=992&new=1&t=1&country=1&c_rus=2&c_ukr=41&c_ec=133&sm=103"

  attr_accessor :directory, :city, :industry

  def initialize(city, industry)
    @directory = Rails.root.join("tmp/rabotaru-#{gg.date_stamp}")
    @city = City.get(city)
    @industry = Industry.get(industry)
  end

  # def load_many
  #   @cities = options[:city] ? City.get( options[:city] ) : City.all
  #   @industries = options[:industry] ? Industry.get( options[:industry] ) : Industry.all
  #   @cities.product(@industries) { |city, industry| load_one(city, industry) }
  # end

  def load
    create_directory
    file_path = "#{directory}/#{city.key}-#{industry.key}.json"
    return if File.size?(file_path)
    
    feed_url = M.interpolate(JsonUrlTemplate, city: city.external_id, industry: industry.external_id)
    feed_json = Http.get(feed_url)
    File.write(file_path, feed_json)
    Log.info 'feed loaded', [city, industry, feed_json.size]
  end  

  private
  
  def create_directory
    # FileUtils.rm_r(directory) if File.exists?(directory)
    Dir.mkdir(directory) unless File.directory?(directory)
  end
end
