require "healthcheck/s3"

Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"
  mount Flipflop::Engine => "/flipflop"

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::SidekiqRedis,
    GovukHealthcheck::Mongoid,
    Healthcheck::S3,
  )

  post "/preview", to: "govspeak#preview"
  get "/error", to: "passthrough#error"

  resources :document_list_export_request, path: "/export/:document_type_slug", param: :export_id, only: [:show]

  resources :finders, param: :document_type_slug do
    member do
      get :metadata, action: :edit_metadata
      post :metadata, action: :update_metadata
      get :facets, action: :edit_facets
      post :facets, action: :update_facets
      post :zendesk, action: :zendesk
    end
  end

  resources :documents, path: "/:document_type_slug", param: :content_id_and_locale, except: :destroy do
    collection do
      resource :export, only: %i[show create], as: :export_documents
    end

    resources :attachments, param: :attachment_content_id, except: %i[index show] do
      get :confirm_delete, on: :member
    end

    get :confirm_unpublish, on: :member
    post :unpublish, on: :member

    get :confirm_publish, on: :member
    post :publish, on: :member

    get :confirm_discard, on: :member
    post :discard, on: :member
  end

  root to: "passthrough#index"
end
