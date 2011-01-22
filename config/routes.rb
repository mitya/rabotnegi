Rabotnegi::Application.routes.draw do
  root :to => 'vacancies#index'
  match "/stylesheets/*id.css" => "less_cache#show"
  
  get 'vacancies/:city/:industry' => 'vacancies#index', :as => :vacancies, 
    :constraints => {:city => /(?!(new|my|\d+))\w*/}, 
    :defaults => {:city => nil, :industry => nil}

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

  match '/simple_captcha/:action' => 'simple_captcha#index', :as => :simple_captcha
  match '/system/:action' => 'system#index', :as => :system
  match '/test/:action' => 'test#index', :as => :test
  match '/sitemap.:format' => 'site#map', :as => :sitemap  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'  
end
