ActionController::Routing::Routes.draw do |map|
  map.nice_vacancies '/vacancies/:city/:industry', :controller => 'vacancies', :action => 'index',
    :defaults => {:city => nil, :industry => nil},
    :requirements => {:city => /(?!(new|my|\d+))\w*/},
    :conditions => { :method => :get }

	map.resources :vacancies, :collection => { :my => :get }
	map.resources :resumes, :collection => { :login => :get, :log_in => :post, :log_out => :get, :my => :get }
	map.resources :employers, :collection => { :log_in => :post, :log_out => :get }
	
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
  map.system '/system/:action', :controller => 'system'
  
  map.root :controller => 'vacancies', :action => 'index'
end