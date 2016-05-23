Rails.application.routes.draw do
  get '/healthcheck', to: proc { [200, {}, ['OK']] }
  get '/rebuild-healthcheck', to: proc { [200, {}, ['OK']] }

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

  resources :documents, path: "/:document_type_slug", param: :content_id, except: :destroy do
    resources :attachments, param: :attachment_content_id, only: [:new, :create, :edit, :update]

    post :withdraw, on: :member
    post :publish, on: :member
  end

  root to: redirect("/manuals")
end
