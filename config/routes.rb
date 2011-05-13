Rabotnegi::Application.routes.draw do
  root :to => 'vacancies#index'

  get 'vacancies(/:city(/:industry))' => 'vacancies#index', :as => :nice_vacancies, :city => Regexp.new(City.all.map(&:code).join('|'))

  resources :vacancies, :only => [:show, :index, :new, :create]
  resource  :resume, :as => :my_resume
  resources :resumes, :only => [:index, :show]

  resource :employer, :only => [:new, :create]

  namespace :employer, :module => nil do
    root to: "employers#welcome"
    post "login" => 'employers#login', as: :login
    get  "logout" => 'employers#logout', as: :logout
    resources :vacancies, controller: "employer_vacancies"
  end

  namespace :worker, :module => nil do
    get  "login" => 'workers#login_page', as: :login
    post "login" => 'workers#login'
    get  "logout" => 'workers#logout', as: :logout
    resources :vacancies, :only => [:create, :destroy], controller: "worker_vacancies"
  end

  namespace :admin, :module => nil do
    root :to => 'site#admin_dashboard'
    resources :vacancies, :module => "admin"
  end

  match '/system/:action', :controller => "site", :as => :system
  match '/sitemap' => 'site#map', :as => :sitemap
  match '/test' => 'site#test'
  match '/test/lorem/(:count)' => 'site#lorem', :count => 5, :as => :lorem

  match '/metal-vacancies(/:city(/:industry))', :to => MetalController.action(:index_vacancies), :city => Regexp.new(City.all.map(&:code).join('|'))
  match '/metal-vacancies/:id', :to => MetalController.action(:show_vacancy)
end
