# coding: utf-8

require 'test_helper'
require 'fileutils'
require 'time'

unit_test RabotaRu::VacancyLoader do
  setup do
    make Vacancy, title: "Designer", city: "spb", industry: "it", external_id: 101, created_at: "2008-09-01", description: "no"
    make Vacancy, title: "Manager", city: "spb", industry: "it", external_id: 102, created_at: "2008-09-01", description: "no"
    
    @loader = PureDelegator.new(RabotaRu::VacancyLoader.new)
    @loader.work_directory = "#{Rails.root}/tmp/rabotaru_test"

    Dir.mkdir(@loader.work_directory) unless File.exists?(@loader.work_directory)
    @work_dir = Dir.new(@loader.work_directory)
  end
  
  teardown do
    Vacancy.delete_all
    RabotaRu::VacancyLoading.delete_all
  end
  
  no_test "directory clearing and remote loading" do
    %w(1.test 2.test 3.test).each { |file| File.new("#{@work_dir.path}/#{file}", 'a') }
    assert_equal 3, Dir["#{@work_dir.path}/*.test"].size
    
    @loader.load_to_files
    
    assert Dir["#{@work_dir.path}/*.test"].empty?
    assert_equal City.all.size * Industry.all.size, @work_dir['*.json'].size
  end
  
  test "load" do
    FileUtils.cp(Dir["#{Rails.root}/test/fixtures/rabotaru/*"], @work_dir.path)
    @loader.skip_remote_loading = true
    @loader.call(:load)
  end
  
  test "filter" do
    load_vacancies
    @loader.filter
    assert  @loader.vacancies.any? { |v| v.title == "A New One" }
    assert  @loader.vacancies.any? { |v| v.title == "Designer" && v.description == 'Updated' }
    assert !@loader.vacancies.any? { |v| v.title == "Manager" }
  end
  
  test "save" do
    load_vacancies
    @loader.filter
    @loader.save
    assert Vacancy.where(title: 'Manager').exists?
    assert Vacancy.where(title: 'A New One').exists?
    assert Vacancy.where(title: 'Designer', description: 'Updated').exists?
  end
  
  def load_vacancies
    @loader.info = RabotaRu::VacancyLoading.create!(:started_at => Time.current)
    @loader.vacancies = [
      Vacancy.new(:title => 'A New One', :city => 'spb', :created_at => "2008-09-01", :external_id => 100, :industry => 'it', :description => 'no'),
      Vacancy.new(:title => 'Designer',  :city => 'msk', :created_at => "2008-09-02", :external_id => 101, :industry => 'it', :description => 'Updated'),
      Vacancy.new(:title => 'Manager',   :city => 'spb', :created_at => "2008-09-01", :external_id => 102, :industry => 'it', :description => 'no')
    ]
  end
end
