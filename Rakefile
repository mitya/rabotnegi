require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'

namespace :db do
	desc "Backups production database on rabotnegi.ru"
	task :backup do
		sh "mysqldump jobs_prod -h rabotnegi.ru -u admin -p123 | bzip2 -c > db#{Time.now.strftime('%Y%m%d-%H%M')}.sql.bz"
	end
end