# rabotnegi.ru
# 6.3  -- rabotnegi.ru/vacancies/msk with database
# 8.1  -- rabotnegi.ru/vacancies/msk no database (class var cache) + system queries (set names, set sql_auto_is_null)
# 31.1 -- rabotnegi.ru/vacancies/327 with database
# 35.5 -- rabotnegi.ru/vacancies/327 without database
# 35   -- no database and no rendering
# 35   -- 2200 bytes of text
# 10.5 -- 20000 bytes of text

# Local
ab -n 30 -c 2 http://127.0.0.1:3000/
httperf --server 127.0.0.1 --port 3000 --num-conns 30 --rate 10 --uri /vacancies/msk # 18kb ~ 6rps

########################################
# Notes
# On heavy requests AB concurency value set to 2 is enough, on 100+ rps actions concurency should be 100-120, otherwice it will fail.

########################################
# PassengerMaxInstancesPerApp 5, less than 4 is slower, but more than 6 is not faster

httperf --server rabotnegi.dev --num-conns 250 --rate 80 --uri /vacancies # 5.4kb ~ 47rps
httperf --server rabotnegi.dev --num-conns 30 --rate 10 --uri /vacancies/msk # 18kb ~ 6.4rps
httperf --server rabotnegi.dev --num-conns 500 --rate 180 --uri /vacancies/20113.ajax # 2.8kb ~ 175rps
httperf --server rabotnegi.dev --num-conns 6000 --rate 2000 --uri /vacancies/20113.ajax # 2.8kb (page cache) ~ 2000+rps

httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/10 # 220rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/20 # 210rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/30 # 206rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/50 # 184rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/99 # 139rps

# Pow (2in) REE Rails 3.0, worker memory 100-120MB
httperf --server rabotnegi.dev --num-conns 250 --rate 70  --uri /vacancies # 47 rps
httperf --server rabotnegi.dev --num-conns 500 --rate 180 --uri /vacancies/20113.ajax # 124 rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/30 # 172 rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/10 # 166 rps
tests 0.92s

## Passenger 3in Ruby 1.9.2 Rails 3.0 worker memory 58MB
httperf --server rabotnegi.local --num-conns 400 --rate 120  --uri /vacancies # 112 rps
httperf --server rabotnegi.local --num-conns 750 --rate 250 --uri /test/lorem/30 # 230 rps
httperf --server rabotnegi.local --num-conns 750 --rate 350 --uri /test/lorem/10 # 305 rps

## Pow (2in) Ruby 1.9.2 Rails 3.0, worker memory 72MB
httperf --server rabotnegi.dev --num-conns 250 --rate 80  --uri /vacancies # 75 rps
httperf --server rabotnegi.dev --num-conns 500 --rate 180 --uri /vacancies/20113.ajax # 150 rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/30 # 177 rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/10 # 249 rps

httperf --server rabotnegi.dev --num-conns 90 --rate 30 --uri /vacancies/msk 
# 18kb ~ 16rps // HAML
# 18kb ~ 19rps // HAML, no url helpers in the loop
# 18kb ~ 19.5rps // ERB
# 18kb ~ 23.3rps // ERB, no url helpers in the loop

tests 0.48s

## Rails server
httperf --server 127.0.0.1 --port 3000 --num-conns 50 --rate 25 --uri /vacancies/msk 
# 14.4 // Haml, no url helpers

httperf --server 127.0.0.1 --port 3000 --num-conns 50 --rate 25 --uri /vacancies/msk 
# 18.1 // Erb, no url helpers


## pow-2in Metal vs Controller, HTML
httperf --server rabotnegi.dev --num-conns 1000 --rate 200 --uri /vacancies/4daebd548c2e8655ab001b6b # 184rps 1146b
httperf --server rabotnegi.dev --num-conns 1000 --rate 200 --uri /metal-vacancies/4daebd548c2e8655ab001b6b # 190rps 1146b

## passenger-2in Metal vs Controller, HTML, 1333B
httperf --server rabotnegi.local --num-conns 1000 --rate 350 --uri /vacancies/4daebd548c2e8655ab001b6b # 263
httperf --server rabotnegi.local --num-conns 1000 --rate 400 --uri /metal-vacancies/4daebd548c2e8655ab001b6b # 286

## passenger-3in Metal vs Controller, HTML, 1333B
httperf --server rabotnegi.local --num-conns 1000 --rate 350 --uri /vacancies/4daebd548c2e8655ab001b6b # 305
httperf --server rabotnegi.local --num-conns 1000 --rate 400 --uri /metal-vacancies/4daebd548c2e8655ab001b6b # 357

## passenger-3in Metal vs Controller, JSON, 2324B
httperf --server rabotnegi.local --num-conns 800 --rate 300 --uri /regular-vacancies/4daebd548c2e8655ab001b6b # 221
httperf --server rabotnegi.local --num-conns 800 --rate 350 --uri /metal-vacancies/4daebd548c2e8655ab001b6b # 306

## passenger-3in Metal vs Controller, JSON, 1368B
httperf --server rabotnegi.local --num-conns 800 --rate 300 --uri /regular-vacancies/4daebd518c2e8655ab00003c # 292
httperf --server rabotnegi.local --num-conns 800 --rate 400 --uri /metal-vacancies/4daebd518c2e8655ab00003c # 344 


MySQL vs Mongo
SELECT id, title, external_id, salary_min, salary_max, employer_name FROM `vacancies` WHERE `vacancies`.`city` = 'msk' ORDER BY title LIMIT #{N} OFFSET 0

VacancyMongo.db.collection("vacancies").find({city: "msk"}, sort: [[:title, Mongo::ASCENDING]], limit: N, :fields => {description: 0}).to_a
VacancyMongo.where(city: "msk").asc("title").paginate(page: params[:page], per_page: N)
Vacancy.connection.select_all("SELECT id, title, external_id, salary_min, salary_max, employer_name FROM `vacancies` WHERE `vacancies`.`city` = 'msk' ORDER BY title LIMIT #{N} OFFSET 0")

10000 records, ix_city_title (all indexed)
Mongo - MySQL - Mongoid - ActiveRecord
1000 rows: 40 14 74 21
100 rows: 5.3 2.2 9 7.5
50 rows: 3 1.7 5 7 
20 rows: 2.2 1.3 2.7 5.5

10000 records, ix_city (filter is indexed, sort field is not)
1000 rows: 68 40 102 49
100 rows: 22 26 29 30
50 rows: 19 25 21 29
20 rows: 17 25 18 29
