namespace :app do
  task :load_demo_data do
    Rails.env = 'test'
    Rake::Task['environment'].invoke

    puts "Loading 100 vacancies into the `#{Rails.env}` database" 
    100.times { Vacancy.create title: "Test", description: "Hello", industry: "it", city: "msk" }
  end
end


namespace :vacancies do
  # Usage: rake vacancies:load CITY=spb INDUSTRY=telework
  task :load => :environment do
    options = {console_logging: true}
    options[:city] = ENV['CITY'] if ENV['CITY'].present?
    options[:industry] = ENV['INDUSTRY'] if ENV['INDUSTRY'].present?

    RabotaRu::VacancyLoader.new(options).load
  end
  
  task :count => :environment do
    puts Vacancy.count
  end  
end
