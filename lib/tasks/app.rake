namespace :app do
  task :load_demo_data do
    Rails.env = 'test'
    Rake::Task['environment'].invoke

    puts "Loading 100 vacancies into the `#{Rails.env}` database" 
    100.times { Vacancy.create title: "Test", description: "Hello", industry: "it", city: "msk" }
  end
end
