require "specialist_publisher"

SpecialistPublisher::Application.routes.draw do
  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails::Engine)
  mount GovukAdminTemplate::Engine, at: "/style-guide"
  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end

  document_types = SpecialistPublisher.document_types.map(&:pluralize)

  document_types.each do |type|
    type_slug = type.to_s.gsub("_", "-")

    resources type.to_sym, controller: type, except: :destroy, path: type_slug do
      resources :attachments, only: [:new, :create, :edit, :update]
      post :withdraw, on: :member
      post :publish, on: :member

      # This is for persisted documents
      post :preview, on: :member
    end

    # This is for new documents
    post "#{type_slug}/preview" => "abstract_documents#preview", as: "preview_new_#{type}"
  end

  # Redirect old specialist-document routes to cma-cases
  get "/specialist-documents", to: redirect("/cma-cases")
  get "/specialist-documents/(*path)", to: redirect { |params, _| "/cma-cases/#{params[:path]}" }

  resources :manuals, except: :destroy do
    resources :documents, except: :destroy, path: "sections", controller: "ManualDocuments" do
      resources :attachments, controller: :manual_document_attachments, only: [:new, :create, :edit, :update]

      # This is for persisted manual documents
      post :preview, on: :member

      get :reorder, on: :collection
      post :update_order, on: :collection
    end

    post :publish, on: :member

    # This is for persisted manuals
    post :preview, on: :member
  end

  # This is for new manualss
  post "manuals/preview" => "Manuals#preview", as: "preview_new_manual"
  # This is for new manual documents
  post "manuals/:manual_id/sections/preview" => "ManualDocuments#preview", as: "preview_new_manual_document"

  root to: redirect("/manuals")
end
