Rails.application.routes.draw do
  get "/healthcheck", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::SidekiqRedis,
  )

  get '/rebuild-healthcheck', to: proc { [200, {}, %w[OK]] }
  post '/preview', to: 'govspeak#preview'
  get '/error', to: 'passthrough#error'

  mount GovukAdminTemplate::Engine, at: "/style-guide"

  resources :passthrough, only: [:index]

  resources :documents, path: "/:document_type_slug", param: :content_id, except: :destroy do
    collection do
      resource :export, only: %i[show create], as: :export_documents
    end
    resources :attachments, param: :attachment_content_id, except: %i[index show]

    post :unpublish, on: :member
    post :publish, on: :member
    post :discard, on: :member
  end

  root to: 'passthrough#index'
end
