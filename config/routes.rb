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
  map.resources :vacancies, :path_prefix => 'employers', :name_prefix => 'employer_', :controller => "employer_vacancies"

  # map.namespace :employers do |emp|
  #   emp.resources :vacancies
  # end
  
  map.workers_login "workers/login", :controller => "workers", :action => "login_page", :conditions => GET
  map.workers_login "workers/login", :controller => "workers", :action => "login", :conditions => POST
  map.workers_logout "workers/logout", :controller => "workers", :action => "logout", :conditions => GET

  map.resources :employers, :collection => { :log_in => :post, :log_out => :get }, :only => [:new, :create, :index]
	map.resources :resumes, :collection => { :login => :get, :log_in => :post, :log_out => :get, :my => :get }
  
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  map.system '/system/:action', :controller => 'system'
  map.test '/test/:action', :controller => 'test'
  map.root :controller => 'vacancies', :action => 'index'
  map.sitemap '/sitemap.:format', :controller => 'site', :action => 'map'
  
  map.namespace :admin do |admin|
		admin.resources :vacancies
    admin.root :controller => 'dashboard', :action => 'show'
  end
  
  map.connect "#{Less::More.destination_path}/*id.css", :controller => 'less_cache', :action => "show"
end
