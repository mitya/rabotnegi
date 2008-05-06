$currency_map = {
	:usd=>"$",
	:eur=>"€",
	:rub=>"руб."
}
$currency_list = [:rub, :usd, :eur]

$salary_table = [
	[-10000, 'до 10 000'],
	[-20000, 'до 20 000'],
	[-30000, 'до 30 000'],
	[-40000, 'до 40 000'],
	[-50000, 'до 50 000'],
	[ 10000, 'от 10 000'],
	[ 20000, 'от 20 000'],
	[ 30000, 'от 30 000'],
	[ 40000, 'от 40 000'],
	[ 50000, 'от 50 000']
]
$salary_inverted_table = $salary_table.map { |v, n| [n, v]}

$city_metadata_table = [
	[:msk, 1, "Москва"],
	[:spb, 2, "Санкт-Петербург"],
	[:ekb, 3, "Екатеринбург"],
	[:nn,  4, "Нижний Новгород"],
	[:nsk, 9, "Новосибирск"]
]
$city_map = {}
$city_list = []
$city_table = []
$city_inverted_table = []
$city_metadata_table.each do |code, ext_id, name|
  $city_map[code] = name
  $city_list << code
  $city_table << [code, name]
  $city_inverted_table << [name, code.to_s]
end

$industry_metadata_table = [
   [:it,                      19, 'Информационные технологии',    :popular],
   [:finance,                  2, 'Бухгалтерия и финансы',        :popular],
   [:transportation,          83, 'Транспорт',                    :popular],
   [:logistics,               78, 'Логистика',                    :popular],
   [:service,                 92, 'Обслуживающий персонал',       :popular],
   [:wholesale,               75, 'Оптовая торговля',             :popular],
   [:manufactoring,           22, 'Производство',                 :popular],
   [:restaurant,              85, 'Рестораны и питание',          :popular],
   [:retail,                  60, 'Розничная торговля',           :popular],
   [:office,                  14, 'Делопроизводство',             :popular],
   [:building,                37, 'Строительство и архитектура',  :popular],
   [:hr,                      12, 'Кадровые службы',              :other],                      
   [:marketing,               49, 'Маркетинг, реклама, PR',       :other],               
   [:medicine,                90, 'Медицина, фармация',           :other],                   
   [:realty,                 107, 'Недвижимость',                 :other],                        
   [:sales,                 1011, 'Продажа услуг',                :other],                      
   [:publishing,              55, 'Издательство, полиграфия',     :other],             
   [:insurance,              109, 'Страхование',                  :other],                         
   [:telecom,                 94, 'Телекоммуникации',             :other],                     
   [:executives,             751, 'Топ-менеджмент',               :other],                      
   [:hospitality,            111, 'Туризм, гостиничное дело',     :other],            
   [:telework,              1006, 'Удаленная работа',             :other],                   
   [:householding,            46, 'Эксплуатация зданий',          :other],                  
   [:law,                      9, 'Юриспруденция',                :other]                          
]

$industry_map = {}            # {:code => 'name', ...}
$popular_industry_table = []  # [[:code, 'name'], ...]
$other_industry_table = []
$popular_industry_inverted_table = []  # [[:code, 'name'], ...]
$other_industry_inverted_table = []
$industry_list = []           # [:code, ...]
for code, ext_id, name, category in $industry_metadata_table do
  $industry_map[code] = name
  $popular_industry_table << [code, name] if category == :popular
  $other_industry_table << [code, name] if category == :other
  $popular_industry_inverted_table << [name, code.to_s] if category == :popular
  $other_industry_inverted_table << [name, code.to_s] if category == :other
  $industry_list << code
end
$popular_industry_table.sort! {|r1, r2| r1[1] <=> r2[1]}
$other_industry_table.sort! {|r1, r2| r1[1] <=> r2[1]}
$popular_industry_inverted_table.sort! {|r1, r2| r1[0] <=> r2[0]}
$other_industry_inverted_table.sort! {|r1, r2| r1[0] <=> r2[0]}
$industry_groups = [['Популярные', $popular_industry_inverted_table], ['Остальные', $other_industry_inverted_table]]

# Неиспользованные отрасли с Работы.ру
# [1009, 'Индустрия красоты'],
# [752, 'Консалтинг, тренинги'],
# [1004, 'Культура и искусство'],
# [1002, 'Лингвистика'],
# [104, 'Охрана, безопасность, милиция'],
# [1008, 'Персонал для дома'],
# [95, 'Образование и наука'],
# [93, 'Продажа по каталогам, MLM'],
# [1007, 'Работа для студентов'],
# [91, 'Работа за рубежом'],
# [1001, 'ТЭК и добыча сырья'],
# [1003, 'Фитнес, спорт'],
# [1005, 'Шоу-бизнес, индустрия развлечений, казино'],