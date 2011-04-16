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

# Pow (2in) Ruby 1.9.2 Rails 3.0, worker memory 72MB
httperf --server rabotnegi.dev --num-conns 250 --rate 80  --uri /vacancies # 75 rps
httperf --server rabotnegi.dev --num-conns 500 --rate 180 --uri /vacancies/20113.ajax # 150 rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/30 # 177 rps
httperf --server rabotnegi.dev --num-conns 750 --rate 250 --uri /test/lorem/10 # 249 rps
tests 0.48s
