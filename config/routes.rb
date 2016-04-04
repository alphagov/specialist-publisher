Rails.application.routes.draw do
  get '/healthcheck', to: proc { [200, {}, ['OK']] }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  mount GovukAdminTemplate::Engine, at: "/style-guide"

  resources :manuals, param: :content_id, except: :destroy do
    post :withdraw, on: :member
    post :publish, on: :member

    resources :sections, param: :content_id, except: :destroy, controller: "manual_sections" do
      resources :attachments, controller: 'manual_sections_attachments', param: :attachment_content_id, only: [:new, :create, :edit, :update]

      get :reorder, on: :collection
      post :update_order, on: :collection
    end
  end

  resources :documents, path: "/:document_type", param: :content_id, except: :destroy do
    resources :attachments, param: :attachment_content_id, only: [:new, :create, :edit, :update]

    post :withdraw, on: :member
    post :publish, on: :member
  end

  root 'documents#index'

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
