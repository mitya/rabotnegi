require "shellwords"

namespace :app do
  task :load_demo_data do
    Rails.env = 'test'
    Rake::Task['environment'].invoke

    puts "Loading 100 vacancies into the `#{Rails.env}` database" 
    100.times { Vacancy.create title: "Test", description: "Hello", industry: "it", city: "msk" }
  end

  task(:load => :environment) { RabotaRu.load }

  namespace :vacancies do
    # Usage: rake vacancies:load CITY=spb INDUSTRY=telework
    task :load => :environment do
      ENV['LOG_TO_CONSOLE'] = 'true'

      options = {}
      options[:city] = ENV['CITY'].shellsplit if ENV['CITY'].present?
      options[:industry] = ENV['INDUSTRY'].shellsplit if ENV['INDUSTRY'].present?

      RabotaRu::VacancyLoader.new(options).load
    end

    task :count => :environment do
      puts Vacancy.count
    end  
  end
end
