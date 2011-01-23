Rabotnegi::Application.routes.draw do
  root :to => 'vacancies#index'
  
  get 'vacancies(/:city(/:industry))' => 'vacancies#index', :as => :nice_vacancies, :city => Regexp.new(City.all.map(&:code).join('|'))
  
  resources :vacancies, :only => [:show, :index]
  resource  :resume  
  resources :resumes, :only => [:index]
  
  resource :employer, :only => [:new, :create]

  namespace :employer, :module => "employers" do
    root :action => "welcome"
    post "login", :action => 'login', :as => :login
    get  "logout", :action => 'logout', :as => :logout
    resources :vacancies
  end

  namespace :worker, :module => "workers" do
    get  "login", :action => 'login_page', :as => :login
    post "login", :action => 'login'
    get  "logout", :action => 'logout', :as => :logout
  end

  namespace :admin do
    root :action => 'dashboard', :as => :dashboard
    resources :vacancies
  end

  match '/system/:action', :controller => "system", :as => :system
  match '/sitemap' => 'site#map', :as => :sitemap
  match '/test' => 'system#test'
end
