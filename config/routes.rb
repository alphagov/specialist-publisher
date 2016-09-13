Rails.application.routes.draw do
  get '/healthcheck', to: proc { [200, {}, ['OK']] }
  get '/rebuild-healthcheck', to: proc { [200, {}, ['OK']] }
  post '/preview', to: 'govspeak#preview'
  get '/error', to: 'passthrough#error'

  mount GovukAdminTemplate::Engine, at: "/style-guide"

  resources :passthrough, only: [:index]

  resources :documents, path: "/:document_type_slug", param: :content_id, except: :destroy do
    resources :attachments, param: :attachment_content_id, except: [:index, :show]

    post :unpublish, on: :member
    post :publish, on: :member
  end

  root to: 'passthrough#index'
end
