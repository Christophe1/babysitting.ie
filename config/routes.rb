QuestionnaireSite::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    delete "sign_out", :to => "devise/sessions#destroy"
    get "login", :to => "devise/sessions#new"
  end

  devise_for :admins, :path => "admin", :controllers => { :sessions => "admin/sessions" }

  get "home/index"
  get "home/map", :as  => :map
  post "home/update_address", :as  => :update_address
  match "canvas" => "canvas#index"

  match "/contacts/:importer/callback" => "email_invites#contacts_callback", :as => :contacts_callback
  match "/contacts/failure" => "email_invites#contacts_callback_failure", :as => :contacts_callback_failure
  mount Resque::Server, :at => "/resque"

  get "find" => 'search#index', :as => :find

  resources :search do
    collection do
      match :change_range
    end
  end

  resources :reviews do
    member do
      get :repost, :reject
    end
  end
  resources :users do
    member do
      get :following_followers, :address_toggle
    end
  end
  resources :friend_relations, :only => [:create, :destroy]
  resources :email_invites do
    collection do
      get :confirm
      post :invitation_form
      post :outlook_import
    end
  end

  root :to => "home#index"

  namespace :admin do
    resource :profile, :only => [:edit, :update]

    resources :users
    resources :categories
    resources :reviews

    root :to => "users#index"
  end

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
