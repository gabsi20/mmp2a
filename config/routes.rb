Rails.application.routes.draw do
  #resources :statuses
  #resources :tasks
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get "/tasks" => 'tasks#index'
  get 'welcome/index'
  get 'sync/calendars' => 'sync#calendars'
  get 'sync/select' => 'sync#select'
  get 'sync/sync' => 'sync#sync'

  post 'task/done' => 'tasks#taskdone'
  post 'task/archive' => 'tasks#taskarchive'
  get 'tasks/archive' => 'tasks#archive'
  get 'tasks/done' => 'tasks#done'
  #resources :calendars
  #resources :users

  # APICALLS - get json
  get "api/:user/open.json" => 'tasks#opentasks_as_json'
  get "api/:user/closed.json" => 'tasks#closedtasks_as_json'
  get "api/:user/archived.json" => 'tasks#archivedtasks_as_json'

  # APICALLS - edit tasks
  post "api/archive" => 'tasks#api_archive_task'
  post "api/toggle" => 'tasks#api_toggle_task'

  # APICALLS - get token
  get "api/gettoken" => 'tasks#api_get_token'

  # MOBILE - LOGIN
  get "ioslogin" => 'pages#ios_login'

  # MOBILE - SYNC
  get 'sync/ios_select' => 'sync#ios_select'

  post "test" => 'tasks#testmethod'
  get "apitoken" => 'apitoken#index'

  get '/signin' => 'pages#index'
  get '/' => 'pages#index'
  get 'pages/:page' => 'pages#show'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#index'

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
