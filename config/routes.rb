# require 'resque/server'

Rabotnegi::Application.routes.draw do
  root :to => 'vacancies#index'

  get 'vacancies(/:city(/:industry))' => 'vacancies#index', :as => :nice_vacancies, :city => Regexp.new(City.all.map(&:code).join('|'))

  resources :vacancies, :only => %w(index show new create)
  resource  :resume, :as => :my_resume
  resources :resumes, :only => %w(index show)

  resource :employer, :only => %w(new create)

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
    resources :vacancies, only: [:create, :destroy], controller: "worker_vacancies" do
      collection { get :favorite }
    end
  end

  namespace :admin, :module => nil do
    root :to => 'admin#dashboard'
    resources :items, controller: "admin_items", path: "data/:collection"
  end

  match '/sitemap' => 'site#map', as: :sitemap

  match '/site/:action', controller: "site"
  match '/test/:action', controller: "test"
  match '/metal-vacancies(/:city(/:industry))', to: MetalController.action(:index_vacancies), :city => Regexp.new(City.all.map(&:code).join('|'))
  match '/metal-vacancies/:id', to: MetalController.action(:show_vacancy)
  
  # mount Resque::Server.new, at: "/admin/resque"
end
