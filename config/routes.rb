ActionController::Routing::Routes.draw do |map|
  GET = { :method => :get } unless defined? GET
  POST = { :method => :post } unless defined? POST
  PUT = { :method => :put } unless defined? PUT
  DELETE = { :method => :delete } unless defined? DELETE

  map.vacancies "vacancies/:city/:industry", :controller => 'vacancies', :action => 'index', :conditions => GET,
    :requirements => {:city => /(?!(new|my|\d+))\w*/}, :defaults => {:city => nil, :industry => nil}

	map.resources :vacancies, :only => :show

  map.resource :employer, :only => [:new, :create] do |employer|
    employer.root :controller => "employers", :action => "welcome", :conditions => GET
    employer.login "login", :controller => "employers", :action => "login", :conditions => POST
    employer.logout "logout", :controller => "employers", :action => "logout", :conditions => GET
    employer.resources :vacancies, :path_prefix => 'employer', :name_prefix => 'employer_', :namespace => "employers/"    
  end
  
  map.resource :worker, :only => :none do |worker|
    worker.login "login", :controller => "workers", :action => "login_page", :conditions => GET
    worker.login "login", :controller => "workers", :action => "login", :conditions => POST
    worker.logout "logout", :controller => "workers", :action => "logout", :conditions => GET
  end

	map.resource :resume
	
	map.resources :resumes, :only => %w(index)
  
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
