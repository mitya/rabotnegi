ActionController::Routing::Routes.draw do |map|
  map.nice_vacancies '/vacancies/:city/:industry', :controller => 'vacancies', :action => 'index',
    :defaults => {:city => nil, :industry => nil},
    :requirements => {:city => /(?!(new|my|\d+))\w*/},
    :conditions => { :method => :get }

	map.resources :vacancies
  map.resources :vacancies, :namespace => 'employers/pro/', :path_prefix => 'employers/pro', :name_prefix => 'pro_employer_'
  map.resources :vacancies, :namespace => 'employers/casual/', :path_prefix => 'employers/casual', :name_prefix => 'casual_employer_'

  map.resources :employers, :collection => { :log_in => :post, :log_out => :get }
	map.resources :resumes, :collection => { :login => :get, :log_in => :post, :log_out => :get, :my => :get }
  
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  map.system '/system/:action', :controller => 'system'
  map.test '/test/:action', :controller => 'test'
  map.root :controller => 'vacancies', :action => 'index'
end