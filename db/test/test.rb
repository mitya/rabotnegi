require "mysql"
require 'benchmark'

begin
	mysql = Mysql.connect("localhost", "root", nil, 'jobs_dev')

	n = 50
	time = Benchmark.realtime do
		# n.times { mysql.query "select * from vacancies where industry = 'it' limit 50" }
		n.times { mysql.query "select id, title, external_id, salary_min, salary_max, employer_name from vacancies where industry = 'it' limit 50" }
	end

	puts "#{time/n}"

ensure
	mysql.close
end

