ActionController::Routing::Routes.draw do |map|
  GET = { :method => :get } unless defined? GET
  POST = { :method => :post } unless defined? POST
  PUT = { :method => :put } unless defined? PUT
  DELETE = { :method => :delete } unless defined? DELETE

  map.nice_vacancies '/vacancies/:city/:industry', :controller => 'vacancies', :action => 'index',
    :requirements => {:city => /(?!(new|my|\d+))\w*/},
    :defaults => {:city => nil, :industry => nil},
    :conditions => { :method => :get }

	map.resources :vacancies, :only => [:index, :show]

  map.resources :employers, :collection => { :log_in => :post, :log_out => :get }, :only => [:new, :create, :index]
  map.resources :vacancies, :path_prefix => 'employers', :name_prefix => 'employer_', :controller => "employer_vacancies"

  map.workers_login "workers/login", :controller => "workers", :action => "login_page", :conditions => GET
  map.workers_login "workers/login", :controller => "workers", :action => "login", :conditions => POST
  map.workers_logout "workers/logout", :controller => "workers", :action => "logout", :conditions => GET

	map.my_resume "resumes/my", :controller => "resumes", :action => "my", :conditions => GET
	map.resources :resumes
  
  map.namespace :admin do |admin|
    admin.root :controller => 'dashboard', :action => 'show', :conditions => GET
		admin.resources :vacancies
  end

  map.root :controller => 'vacancies', :action => 'index', :conditions => GET
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  map.system '/system/:action', :controller => 'system'
  map.test '/test/:action', :controller => 'test'
  map.sitemap '/sitemap.:format', :controller => 'site', :action => 'map'
  
  map.connect "#{Less::More.destination_path}/*id.css", :controller => 'less_cache', :action => "show"
end
