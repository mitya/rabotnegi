require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'pp'

Rabotnegi::Application.load_tasks

namespace :data do
  desc "Backups production database on rabotnegi.ru"
  task :sql_backup do
    sh "mysqldump jobs_prod -h rabotnegi.ru -u admin -p123 | bzip2 -c > db#{Time.now.strftime('%Y%m%d-%H%M')}.sql.bz"
  end
  
  # cap crake TASK="data:dump dest=/apps/data db=rabotnegi_prod"
  # rake data:dump dest=/apps/data db=rabotnegi_prod
  # scp rba:/apps/data/dump-latest.tbz ~/desktop
  task :dump do
    db = ENV['db']
    dest = ENV['dest']
    num = Time.now.strftime("%Y%m%d-%H%M%S")
    
    sh "mongodump -d #{db} -o tmp/dump-#{num}"
    sh "tar -C tmp -cj dump-#{num} > #{dest}/dump-#{num}.tbz"
    sh "rm -rf tmp/dump-#{num} #{dest}/dump-latest.tbz"
    sh "ln -s #{dest}/dump-#{num}.tbz #{dest}/dump-latest.tbz"
  end 
  
  task :clone do
    source = "rabotnegi_dev"
    target = "rabotnegi_test_real"
    sh "rm -rf tmp/dbclone/#{source}"
    sh "mongodump -d #{source} -o tmp/dbclone"
    sh "mongorestore -d #{target} --drop tmp/dbclone/#{source}"
    sh "rm -rf tmp/dbclone/#{source}"
  end
  
  # rake data:seed[web]
  # rails runner -e test_web test/fixtures/data.rb
  task :seed, [:dataset_name] => [:environment] do |t, args|
    file = case args.dataset_name
      when 'web' then "test/fixtures/data.rb"
    end
    [Vacancy, User, MongoLog::Item].each(&:delete_all)
    load(file)
    puts "Seeded #{Rails.env} - #{{vacancies: Vacancy.count, users: User.count}.inspect}"
  end
  
  task :restore_dev do
    sh "mongorestore -d rabotnegi_dev --drop #{ENV['src']}"
  end
end

namespace :app do
  task(:load => :environment) { RabotaRu.load }
end

namespace :dev do
  task :rm do
    system "rm -rf #{Rails.root}/public/javascripts/pack"
    system "rm -rf #{Rails.root}/public/stylesheets/pack"
    system "rm -rf #{Rails.root}/tmp/cache/*"
    system "rm -rf #{Rails.root}/public/vacancies"
  end
end

namespace :test do
  task :web do
    sh "rake test:web_internal X_RAILS_ENV=test_web"
  end

  Rake::TestTask.new(:web_internal) do |t|
    t.libs << "test"
    t.pattern = 'test/web/**/*_test.rb'
    t.verbose = true
    t.options = "--verbose=verbose"
  end
  
  task :web_seed do
    sh "rake data:seed[web] RAILS_ENV=test_web"
  end
end
