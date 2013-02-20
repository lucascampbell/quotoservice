require 'resque/server'
QuotesService::Application.routes.draw do
  devise_for :users

  match 'quotes/:id/activate'   => 'quotes#activate'
  match 'quotes/:id/deactivate' => 'quotes#deactivate'
  match 'quotes/search'         => 'quotes#search', :via=>[:post,:get]
  match 'quotes/notes_save'     => 'quotes#notes_save', :via=>:get
  resources :quotes
  resources :topics
  resources :tags
  
  #API V1
  match 'api/v1/get_quotes'      => 'api#get_quotes',      :via=>:get
  match 'api/v1/set_quote'       => 'api#set_quote',       :via=>:post
  match 'api/v1/register_device' => 'api#register_device', :via =>:post
  
  #API V2
  match 'api/v2/get_quotes'      => 'api#get_updates',      :via=>:get
  match 'api/v2/set_quote'       => 'api#set_quote',       :via=>:post
  match 'api/v2/register_device' => 'api#register_device', :via =>:post
  match 'api/v2/snapshot'        => 'api#snapshot',       :via =>:get
  
  #Push
  match 'push/index'                    => 'push#index'
  match 'push/edit_priority'            => 'push#edit_priority',   :via=>:get
  match 'push/send_push'                => 'push#send_remote_push', :via=>:get
  match 'push/delete/:id'               => 'push#delete',          :via=>:delete
  match 'push/delete_remote/:id/:name'  => 'push#delete_remote',   :via=>:delete
  mount Resque::Server.new, :at => "/resque"
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
   root :to => 'quotes#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
