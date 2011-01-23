Rabotnegi::Application.routes.draw do
  root :to => 'vacancies#index'
  
  get 'vacancies(/:city(/:industry))' => 'vacancies#index', :as => :nice_vacancies, :city => Regexp.new(City.all.map(&:code).join('|'))
  
  resources :vacancies, :only => [:show, :index]
  resource  :resume  
  resources :resumes, :only => [:index]
  
  resource :employer, :only => [:new, :create]
  namespace :employer do  
    root :to => "employers#welcome"
    post 'login' => 'employers#login', :as => :login
    get  'logout' => 'employers#logout', :as => :logout
    resources :vacancies
  end
  
  resource :worker, :only => []
  namespace :worker do  
    get  'login' => 'workers#login_page', :as => :login
    post 'login' => 'workers#login', :as => :login
    get  'logout' => 'workers#logout', :as => :logout
  end
  
  namespace :admin do
    root :to => 'admin#dashboard', :as => :dashboard
    resources :vacancies
  end
  
  match '/system/:action', :controller => "system", :as => :system
  match '/sitemap' => 'site#map', :as => :sitemap
  match '/test' => 'system#test'

  # match ':controller(/:action(/:id(.:format)))'
end
