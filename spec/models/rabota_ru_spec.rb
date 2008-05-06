require 'spec/spec_helper'
require 'fileutils'
require 'xmlsimple'
require 'time'

describe RabotaRu::VacancyLoader do
  fixtures :vacancies
  
  before :each do
    @loader = RabotaRu::VacancyLoader.new_private_accessor

    work_dir_path = @loader.work_directory
    Dir.mkdir(work_dir_path) unless File.exists?(work_dir_path)
		@work_dir = Dir.new(work_dir_path)
  end
  
  nit "empties work dir before loading" do
		@work_dir.create_files('1.test', '2.test', '3.test')
		@work_dir['*.test'].count.should == 3
		
		@loader.load_to_files
		
		@work_dir['*.test'].should be_empty
		@work_dir['*.rss'].count.should == $city_list.size * $industry_list.size
  end
  
  nit "loads data" do
    FileUtils.cp(Dir["#{RAILS_ROOT}/spec/fixtures/rabotaru/*"], "#{RAILS_ROOT}/tmp/rabotaru")
    @loader.skip_remote_loading = true
    @loader.load
  end
  
  it "filters loaded data to exclude already loaded vacancies" do
		load_vacancies
		@loader.filter
		loaded_vacancies = @loader.instance_variable_get(:@loaded_vacancies)
		loaded_vacancies.should_be_any { |v| v.external_id == 102 }
		loaded_vacancies.should_be_any { |v| v.external_id == 101 && v.title == 'Designer (upd)' && !v.new_record? }
		loaded_vacancies.should_not_be_any { |v| v.external_id == 100 }
  end
  
  it "saves vacancies after filtration" do
		load_vacancies
		@loader.filter
		@loader.save
		Vacancy.should_exists(:title => 'Manager')
		Vacancy.should_exists(:title => 'Designer (upd)')
  end
  
  def load_vacancies
		loaded_vacancies = [
			Vacancy.new(:title => 'Developer', :city => :spb, :created_at => Time.local(2008, 1, 1), :external_id => 100, :industry => :it, :description => 'no'),
			Vacancy.new(:title => 'Designer (upd)', :city => :msk, :created_at => Time.local(2008, 1, 2), :external_id => 101, :industry => :it, :description => 'no'),
			Vacancy.new(:title => 'Manager', :city => :spb, :created_at => Time.local(2007, 1, 2), :external_id => 102, :industry => :it, :description => 'no')
		]
		@loader.instance_variable_set(:@loaded_vacancies, loaded_vacancies)
  end
end

describe RabotaRu::VacancyConverter do
  before :all do
    @@rss_item_text = %{
			<item>
				<description><![CDATA[Описание]]></description>
				<guid>http://www.rabota.ru/vacancy9687746.html</guid>
				<vacancy:date vacancy:publishDate="Wed, 12 Sep 2007 12:50:00 +0400" />
				<vacancy:rubric_0 vacancy:number="19">IT, компьютеры, работа в интернете</vacancy:rubric_0>
				<vacancy:city vacancy:number="1">Москва</vacancy:city>
				<vacancy:position>Менеджер по продажам</vacancy:position>
				<vacancy:employer vacancy:number="49950">MyTOSHIBA</vacancy:employer>
				<vacancy:salary vacancy:min="800" vacancy:max="2000" vacancy:currency="USD"/>
				<vacancy:responsibility>Обязанности</vacancy:responsibility>
			</item>
		}
		@@rss_item_hash = XmlSimple.xml_in(@@rss_item_text, 'forcearray' => false)
		@@expected_vacancy = Vacancy.new(
			:title=>'Менеджер по продажам',
			:city=>:msk,
			:industry=>:it,
			:external_id=>9687746,
			:description=>'Описание',
			:employer_name=>'MyTOSHIBA',
			:created_at=>Time.xmlschema('2007-09-12T12:50:00+04:00'),
			:salary=>Salary.new(:min=>20000, :max=>50000, :currency=>:rub)
		)
  end
  
  before :each do
    @converter = RabotaRu::VacancyConverter.new_private_accessor
  end
  
  it "converts Rabota.ru XML into object" do
    @converter.convert(@@rss_item_hash).should == @@expected_vacancy
  end
  
  it "formats description literally, and ignores responsibility" do
    @converter.format_description('desc', 'resp').should == 'desc'
  end
  
  it "extracts external ID from URL" do
		@converter.extract_id('http://www.rabota.ru/vacancy1234567.html').should == 1234567
  end
  
  it "converts external city IDs to internal codes" do
		@converter.find_city(4).should == :nn
		@converter.find_city(1).should == :msk
	end
	
  it "converts external industry IDs to internal codes" do
		@converter.find_industry(94).should == :telecom
	end
	
	it "converts salaries" do
		should_convert_salary({:negotiable => true}, '<vacancy:salary vacancy:agreed="yes"/>')
		should_convert_salary({:max => 25000, :currency => :rub}, '<vacancy:salary vacancy:min="" vacancy:max="1000" vacancy:currency="USD"/>')
		should_convert_salary({:exact => 1000, :currency => :rub}, '<vacancy:salary vacancy:min="1000" vacancy:max="1000" vacancy:currency="руб"/>')
		should_convert_salary({:min => 17000, :max => 34000, :currency => :rub}, '<vacancy:salary vacancy:min="500" vacancy:max="1000" vacancy:currency="EUR"/>')
	end
	
  it "converts currencies" do
		@converter.convert_currency('руб').should == :rub
		@converter.convert_currency('USD').should == :usd
		@converter.convert_currency('EUR').should == :eur
    lambda { @converter.convert_currency('GBP') }.should raise_error(ArgumentError)
    lambda { @converter.convert_currency(nil) }.should raise_error(ArgumentError)
	end
	
	def should_convert_salary(expected_salary_parameters, salary_xml)
	  salary_hash = XmlSimple.xml_in(salary_xml, 'forcearray' => false)
		result = @converter.convert_salary(salary_hash)
		result.should == Salary.new(expected_salary_parameters)
	end
end