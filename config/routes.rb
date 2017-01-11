Rails.application.routes.draw do

  # MUST come first (before the `api` namespace):
  # https://github.com/lynndylanhurley/devise_token_auth#can-i-use-this-gem-alongside-standard-devise
  devise_for :users
  # Required for Devise
  root 'welcome#index'
  # Token auth routes available at `/api/auth`
  namespace :api, defaults: { format: :json } do
    mount_devise_token_auth_for 'User', at: 'auth'
  end

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

  post 'recommendations/update_admin_seeds' => 'recommendation_seeds#update_admin_recommendations', as: :update_admin_recommendations

  put 'providers/update_all' => 'providers#update_all', as: :update_all_providers
  get 'providers/names' => 'providers#names', as: :provider_names
  get 'providers' => 'providers#index', as: :providers

  get 'applications' =>'ingredients#applications', as: :applications
  get 'templates' =>'ingredients#templates', as: :templates
  delete 'recommendations/:recommendation_id' => 'deployment_recommendations#destroy', as: :delete_recommendation

  resources :ingredients, concerns: [:paginatable] do
    post 'trigger_range' => 'deployment_recommendations#trigger_range', as: :trigger_range
    get 'recommendations_completed' => 'ingredients#recommendations_completed', as: :recommendations_completed
    get 'recommendations' => 'deployment_recommendations#index', as: :recommendations
    delete 'recommendations' => 'deployment_recommendations#destroy_all', as: :destroy_all_recommendations
    get 'has_recommendations' => 'deployment_recommendations#has_recommendations', as: :has_recommendations
    get 'copy' => 'ingredients#copy', as: :copy_ingredient
    get 'template' => 'ingredients#template', as: :make_template
    get 'instance' => 'ingredients#instance', as: :instance
    get 'instances' =>'ingredients#instances', as: :instances
  end

  resources :constraints, only: [:show, :index, :destroy, :create, :update], concerns: [:paginatable]

  resources :ram_workloads, only: [:show, :index, :destroy, :create, :update, :new], concerns: [:paginatable]

  resources :cpu_workloads, only: [:show, :index, :destroy, :create, :update, :new], concerns: [:paginatable]

  resources :traffic_workloads, only: [:show, :index, :destroy, :create, :update, :new], concerns: [:paginatable]

  resources :scaling_workloads, concerns: [:paginatable]

  get 'resources_region_areas' => 'resources#region_areas', as: :region_areas
  resources :resources, only: [:show, :index], concerns: [:paginatable]


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
