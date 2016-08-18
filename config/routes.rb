Rails.application.routes.draw do

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  concern :copyable do
    get 'copy/:copy', action: :new, on: :collection, as: :copy
  end

  # get 'jobs' => 'jobs#index'

  resources :jobs, only:[:index, :show, :destroy] do
    get 'run' => 'jobs#run', as: :run
  end


  put 'providers/update_all' => 'providers#update_all', as: :update_all_providers
  get 'providers/names' => 'providers#names', as: :provider_names
  get 'providers' => 'providers#index', as: :providers

  get 'applications' =>'ingredients#applications', as: :applications
  get 'templates' =>'ingredients#templates', as: :templates

  resources :ingredients, concerns: [:paginatable] do
    put 'trigger_recommendation' => 'deployment_recommendations#trigger', as: :trigger_recommendation
    get 'recommendations' => 'deployment_recommendations#index', as: :recommendations
    get 'copy' => 'ingredients#copy', as: :copy_ingredient
    get 'template' => 'ingredients#template', as: :make_template
    get 'instance' => 'ingredients#instance', as: :instance
    get 'instances' =>'ingredients#instances', as: :instances
  end

  resources :constraints, only: [:show, :index, :destroy, :create, :update], concerns: [:paginatable]

  resources :workloads, only: [:show, :index, :destroy, :create, :update, :new], concerns: [:paginatable]

  resources :resources, only: [:show, :index], concerns: [:paginatable]

  get 'workloads/new/:ingredient_id' => 'workloads#new'

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
