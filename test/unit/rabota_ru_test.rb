require 'test_helper'
require 'fileutils'
require 'xmlsimple'
require 'time'

# unit_test RabotaRu::VacancyLoader do
#   fixtures :vacancies
#   
#   def setup
#     @loader = PureDelegator.new(RabotaRu::VacancyLoader)
# 
#     work_dir_path = @loader.work_directory
#     Dir.mkdir(work_dir_path) unless File.exists?(work_dir_path)
#     @work_dir = Dir.new(work_dir_path)
#   end
#   
#   test "directory clearing" do
#     %(1.test 2.test 3.test).each { |file| File.new("#{@work_dir_path}/#{file}", 'a') }
#     Dir["#{@work_dir_path}/*.test"].count.should == 3
#     
#     @loader.load_to_files
#     
#     assert Dir["#{@work_dir_path}/*.test"].empty?
#     assert_equal $city_list.size * $industry_list.size, @work_dir['*.rss'].count
#   end
#   
#   test "loading" do
#     FileUtils.cp(Dir["#{RAILS_ROOT}/spec/fixtures/rabotaru/*"], "#{RAILS_ROOT}/tmp/rabotaru")
#     @loader.skip_remote_loading = true
#     @loader.load
#   end
#   
#   test "filtration" do
#     load_vacancies
#     @loader.filter
#     loaded_vacancies = @loader.instance_variable_get(:@loaded_vacancies)
#     assert loaded_vacancies.any? { |v| v.external_id == 102 }
#     assert !loaded_vacancies.any? { |v| v.external_id == 101 && v.title == 'Designer (upd)' && !v.new_record? }
#     assert loaded_vacancies.any? { |v| v.external_id == 100 }
#   end
#   
#   test "saving" do
#     load_vacancies
#     @loader.filter
#     @loader.save
#     assert Vacancy.exists?(:title => 'Manager')
#     assert Vacancy.exists?(:title => 'Designer (upd)')
#   end
#   
#   def load_vacancies
#     loaded_vacancies = [
#       Vacancy.new(:title => 'Developer', :city => :spb, :created_at => Time.local(2008, 1, 1), :external_id => 100, :industry => :it, :description => 'no'),
#       Vacancy.new(:title => 'Designer (upd)', :city => :msk, :created_at => Time.local(2008, 1, 2), :external_id => 101, :industry => :it, :description => 'no'),
#       Vacancy.new(:title => 'Manager', :city => :spb, :created_at => Time.local(2007, 1, 2), :external_id => 102, :industry => :it, :description => 'no')
#     ]
#     @loader.instance_variable_set(:@loaded_vacancies, loaded_vacancies)
#   end
# end
# 
# unit_test RabotaRu::VacancyConverter do
#   def setup
#     @@rss_item_text = %{
#       <item>
#         <description><![CDATA[Описание]]></description>
#         <guid>http://www.rabota.ru/vacancy9687746.html</guid>
#         <vacancy:date vacancy:publishDate="Wed, 12 Sep 2007 12:50:00 +0400" />
#         <vacancy:rubric_0 vacancy:number="19">IT, компьютеры, работа в интернете</vacancy:rubric_0>
#         <vacancy:city vacancy:number="1">Москва</vacancy:city>
#         <vacancy:position>Менеджер по продажам</vacancy:position>
#         <vacancy:employer vacancy:number="49950">MyTOSHIBA</vacancy:employer>
#         <vacancy:salary vacancy:min="800" vacancy:max="2000" vacancy:currency="USD"/>
#         <vacancy:responsibility>Обязанности</vacancy:responsibility>
#       </item>
#     }
#     @@rss_item_hash = XmlSimple.xml_in(@@rss_item_text, 'forcearray' => false)
#     @@expected_vacancy = Vacancy.new(
#       :title=>'Менеджер по продажам',
#       :city=>:msk,
#       :industry=>:it,
#       :external_id=>9687746,
#       :description=>'Описание',
#       :employer_name=>'MyTOSHIBA',
#       :created_at=>Time.xmlschema('2007-09-12T12:50:00+04:00'),
#       :salary=>Salary.make(:min=>20000, :max=>50000, :currency=>:rub)
#     )
# 
#     @converter = PureDelegator.new(RabotaRu::VacancyConverter.new)
#   end
#   
#   test "convertion" do
#     assert_equal @@expected_vacancy, @converter.convert(@@rss_item_hash) 
#   end
#   
#   test "description formatting" do
#     assert_equal 'desc', @converter.format_description('desc', 'resp')
#   end
#   
#   test "extraction of ID from URL" do
#     assert_equal 1234567, @converter.extract_id('http://www.rabota.ru/vacancy1234567.html')
#   end
#   
#   test "convertion of external city IDs to internal codes" do
#     assert_equal :nn, @converter.find_city(4)
#     assert_equal :msk, @converter.find_city(1)
#   end
#   
#   test "convertion of external industry IDs to internal codes" do
#     assert_equal :telecom, @converter.find_industry(94)
#   end
#   
#   test "convertion of salaries" do
#     assert_convert_salary({:negotiable => true}, '<vacancy:salary vacancy:agreed="yes"/>')
#     assert_convert_salary({:max => 25000, :currency => :rub}, '<vacancy:salary vacancy:min="" vacancy:max="1000" vacancy:currency="USD"/>')
#     assert_convert_salary({:exact => 1000, :currency => :rub}, '<vacancy:salary vacancy:min="1000" vacancy:max="1000" vacancy:currency="руб"/>')
#     assert_convert_salary({:min => 17000, :max => 34000, :currency => :rub}, '<vacancy:salary vacancy:min="500" vacancy:max="1000" vacancy:currency="EUR"/>')
#   end
#   
#   test "convertion of currencies" do
#     assert_equal :rub, @converter.convert_currency('руб')
#     assert_equal :usd, @converter.convert_currency('USD')
#     assert_equal :eur, @converter.convert_currency('EUR')  
#     assert_raise(ArgumentError) { @converter.convert_currency('GBP') }
#     assert_raise(ArgumentError) { @converter.convert_currency(nil) }
#   end
#   
#   def assert_convert_salary(expected_salary_parameters, salary_xml)
#     salary_hash = XmlSimple.xml_in(salary_xml, 'forcearray' => false)
#     result = @converter.convert_salary(salary_hash)
#     assert_equal Salary.make(expected_salary_parameters), result
#   end
# end