require 'test_helper'
require 'fileutils'
require 'xmlsimple'
require 'time'

unit_test RabotaRu::VacancyLoader do
  fixtures :vacancies
  
  def setup
    @loader = PureDelegator.new(RabotaRu::VacancyLoader.new)
    @loader.work_directory = "#{Rails.root}/tmp/rabotaru_test"

    Dir.mkdir(@loader.work_directory) unless File.exists?(@loader.work_directory)
    @work_dir = Dir.new(@loader.work_directory)
  end
  
  xtest "directory clearing and remote loading" do
    %w(1.test 2.test 3.test).each { |file| File.new("#{@work_dir.path}/#{file}", 'a') }
    assert_equal 3, Dir["#{@work_dir.path}/*.test"].size
    
    @loader.load_to_files
    
    assert Dir["#{@work_dir.path}/*.test"].empty?
    assert_equal City.all.size * Industry.all.size, @work_dir['*.json'].size
  end
  
  test "loading" do
    FileUtils.cp(Dir["#{Rails.root}/test/fixtures/rabotaru/*"], @work_dir.path)
    @loader.skip_remote_loading = true
    @loader.load
  end
  
  test "filtration" do
    load_vacancies
    @loader.filter
    filtered_vacancies = @loader.instance_variable_get(:@loaded_vacancies)
    assert  filtered_vacancies.any? { |v| v.external_id == 100 }
    assert  filtered_vacancies.any? { |v| v.external_id == 101 && v.description == 'new' }
    assert !filtered_vacancies.any? { |v| v.external_id == 102 }
  end
  
  test "saving" do
    load_vacancies
    @loader.filter
    @loader.save
    assert Vacancy.exists?(:title => 'Manager')
    assert Vacancy.exists?(:title => 'Designer', :description => 'new')
  end
  
  def load_vacancies
    loaded_vacancies = [
      Vacancy.new(:title => 'Developer', :city => 'spb', :created_at => Time.utc(2008, 9, 1), :external_id => 100, :industry => 'it', :description => 'no'),
      Vacancy.new(:title => 'Designer',  :city => 'msk', :created_at => Time.utc(2008, 9, 2), :external_id => 101, :industry => 'it', :description => 'new'),
      Vacancy.new(:title => 'Manager',   :city => 'spb', :created_at => Time.utc(2008, 9, 1), :external_id => 102, :industry => 'it', :description => 'no')
    ]
    @loader.instance_variable_set(:@loaded_vacancies, loaded_vacancies)
  end
end


unit_test RabotaRu::VacancyConverter do
  def setup
    @@hash = ActiveSupport::JSON.decode('{
      "publishDate": "Fri, 19 Sep 2008 20:07:18 +0400",
      "expireDate": "Fri, 26 Sep 2008 20:07:18 +0400",
      "position": "Менеджер",
      "link": "http://www.rabota.ru/vacancy27047845.html",
      "description": "blah-blah-blah-blah-blah", 
      "rubric_0": {"id": "19", "value": "IT, компьютеры, работа в интернете"}, 
      "rubric_1": {"id": "14", "value": "Секретариат, делопроизводство, АХО"}, 
      "rubric_2": {"id": "12", "value": "Кадровые службы, HR"}, 
      "city": {"id": "2", "value": "Санкт-Петербург"}, 
      "schedule": {"id": "1", "value": "полный рабочий день"}, 
      "education": {"id": "3", "value": "неполное высшее"}, 
      "experience": {"id": "2", "value": "до 2 лет"}, 
      "employer": {"id": "15440", "value": "Apple", "link": "http://www.rabota.ru/agency15440.html"}, 
      "salary": {"min": "20000", "max": "30000", "currency": {"value": "руб", "id": "2"}}, 
      "responsibility": {"value": "blah-blah-blah"}
    }')
    
    @@expected_vacancy = Vacancy.new(
      :title => 'Менеджер',
      :city => 'spb',
      :industry => 'it',
      :external_id => 27047845,
      :employer_name => 'Apple',
      :description => 'blah-blah-blah',
      :created_at => Time.parse('Fri, 19 Sep 2008 20:07:18 +0400'),
      :salary => Salary.make(:min => 20000, :max => 30000, :currency => :rub)
    )

    @converter = PureDelegator.new(RabotaRu::VacancyConverter.new)
  end
  
  test "conversion" do
    assert_equal @@expected_vacancy.attributes, @converter.convert(@@hash).attributes
  end
  
  test "extraction of ID from URL" do
    assert_equal 1234567, @converter.extract_id('http://www.rabota.ru/vacancy1234567.html')
  end
  
  test "conversion of salaries" do
    assert_equal Salary.make(:negotiable => true), @converter.convert_salary('agreed' => 'yes')
    assert_equal Salary.make(:max => 25000, :currency => :rub), @converter.convert_salary('max' => '25000', 'currency' => {'value' => 'руб'})
    assert_equal Salary.make(:exact => 25000, :currency => :rub), @converter.convert_salary('min' => '25000', 'max' => '25000', 'currency' => {'value' => 'руб'})
    assert_equal Salary.make(:min => 17000, :max => 34000, :currency => :rub), @converter.convert_salary('min' => '17000', 'max' => '34000', 'currency' => {'value' => 'руб'})
  end
  
  test "conversion of currencies" do
    assert_equal :rub, @converter.convert_currency('value' => 'руб')
    assert_equal :usd, @converter.convert_currency('value' => 'usd')
    assert_equal :eur, @converter.convert_currency('value' => 'eur')  
    assert_equal :rub, @converter.convert_currency('value' => 'gbp')
  end
end
