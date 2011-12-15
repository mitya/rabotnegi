require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'pp'
require 'resque/tasks'

Rabotnegi::Application.load_tasks

namespace :data do
  # cap crake TASK="data:dump dest=/apps/data db=rabotnegi_prod"
  # rake data:dump dest=/apps/data db=rabotnegi_prod
  # scp rba:/apps/data/dump-latest.tbz ~/desktop
  task :dump do
    db = ENV['db']
    dest = ENV['dest']
    id = Time.now.strftime("%Y%m%d-%H%M%S")
    
    sh "mongodump -d #{db} -o tmp/dump-#{id}"
    sh "tar -C tmp -cj dump-#{num} > #{dest}/dump-#{id}.tbz"
    sh "rm -rf tmp/dump-#{id} #{dest}/dump-latest.tbz"
    sh "ln -s dump-#{id}.tbz #{dest}/dump-latest.tbz"
  end 
  
  task :clone do
    source = "rabotnegi_dev"
    target = "rabotnegi_test_real"
    sh "rm -rf tmp/dbclone/#{source}"
    sh "mongodump -d #{source} -o tmp/dbclone"
    sh "mongorestore -d #{target} --drop tmp/dbclone/#{source}"
    sh "rm -rf tmp/dbclone/#{source}"
  end
  
  task :restore do
    sh "mongorestore -d rabotnegi_dev --drop #{ENV['src']}"
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
end

namespace :dev do
  task :rm do
    system "rm -rf #{Rails.root}/public/javascripts/pack"
    system "rm -rf #{Rails.root}/public/stylesheets/pack"
    system "rm -rf #{Rails.root}/tmp/cache/*"
    system "rm -rf #{Rails.root}/public/vacancies"
  end  
end

namespace :cron do
  task :ping => :environment  do
    Rails.logger.info "Cron is still alive. Event.count=#{MongoLog::Item.count}"
  end
end

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
end

task "jobs:work" => "resque:work"
