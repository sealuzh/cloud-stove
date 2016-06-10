Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  
  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end
  
  concern :copyable do
    get 'copy/:copy', action: :new, on: :collection, as: :copy
  end


  put 'providers/update_all' => 'providers#update_all', as: :update_all_providers
  get 'providers' => 'providers#index', as: :providers

  get 'applications' =>'ingredients#applications', as: :applications
  # get 'ingredients/copy/:copy' => 'ingredients#copy', as: :copy_ingredient

  resources :ingredients, concerns: [:paginatable] do
    put 'trigger_recommendation' => 'deployment_recommendations#trigger', as: :trigger_recommendation
    get 'recommendation' => 'deployment_recommendations#show', as: :recommendation
    get 'copy' => 'ingredients#copy', as: :copy_ingredient
  end

  resources :constraints, only: [:show, :index, :destroy, :create, :update], concerns: [:paginatable]

  resources :resources, only: [:show, :index], concerns: [:paginatable]

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
