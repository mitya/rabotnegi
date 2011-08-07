require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'pp'

Rabotnegi::Application.load_tasks

namespace :data do
  desc "Backups production database on rabotnegi.ru"
  task :sql_backup do
    sh "mysqldump jobs_prod -h rabotnegi.ru -u admin -p123 | bzip2 -c > db#{Time.now.strftime('%Y%m%d-%H%M')}.sql.bz"
  end
  
  task :dump do
    sh "mongodump -d rabotnegi_demo -o tmp/dump-#{Time.now.strftime("%Y%m%d-%H%M%S")}"
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
