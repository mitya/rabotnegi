ActionController::Routing::Routes.draw do |map|
  map.nice_vacancies '/vacancies/:city/:industry', :controller => 'vacancies', :action => 'index',
    :requirements => {:city => /(?!(new|my|\d+))\w*/},
    :defaults => {:city => nil, :industry => nil},
    :conditions => { :method => :get }

	map.resources :vacancies, :only => [:index, :show]
  map.resources :vacancies, :namespace => 'employers/pro/', :path_prefix => 'employers/pro', :name_prefix => 'pro_employer_'
  map.resources :vacancies, :namespace => 'employers/casual/', :path_prefix => 'employers/casual', :name_prefix => 'casual_employer_', :only => [:new, :create]

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
