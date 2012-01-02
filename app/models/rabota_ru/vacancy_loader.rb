# Loads the vacancies feed into tmp/rabotaru-DATE/CITY-INDUSTRY.rss
class RabotaRu::VacancyLoader
  FeedUrlTemplate = "http://www.rabota.ru/v3_jsonExport.html?wt=f&c={city}&r={industry}&ot=t&cu=2&p=30&d=desc&cs=t&start=0&pp=50&fv=f&rc=992&new=1&t=1&country=1&c_rus=2&c_ukr=41&c_ec=133&sm=103"

  attr_accessor :working_directory, :city, :industry

  def initialize(city, industry)
    @working_directory = Rails.root.join("tmp", "#{Se.rabotaru_dir}-#{Mu.date_stamp}")
    @city = City.get(city)
    @industry = Industry.get(industry)
  end

  def load
    create_working_directory
    feed_file = working_directory.join("#{city.key}-#{industry.key}.json")
    return if File.size?(feed_file)
    
    feed_url = Mu.interpolate(FeedUrlTemplate, city: city.external_id, industry: industry.external_id)
    feed_json = Http.get(feed_url)
    File.write(feed_file, feed_json)
    Mu.info 'feed loaded', [city, industry, feed_json.size]
  end  

  private
  
  def create_working_directory
    Dir.mkdir(working_directory) unless File.directory?(working_directory)
  end
end
