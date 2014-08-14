SpecialistPublisher::Application.routes.draw do
  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails::Engine)
  mount GovukAdminTemplate::Engine, at: "/style-guide"
  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :cma_cases, except: :destroy, path: "cma-cases" do
    resources :attachments, controller: :cma_case_attachments, only: [:new, :create, :edit, :update]
    post :withdraw, on: :member
    post :publish, on: :member

    # This is for persisted cma cases
    post :preview, on: :member
  end

  # This is for new cma cases
  post "cma-cases/preview" => "cma_cases#preview", as: "preview_new_cma_case"

  # Redirect old specialist-document routes to cma-cases
  get "/specialist-documents", to: redirect("/cma-cases")
  get "/specialist-documents/(*path)", to: redirect { |params, _| "/cma-cases/#{params[:path]}" }

  resources :aaib_reports, except: :destroy, path: "aaib-reports" do
    resources :attachments, controller: :aaib_report_attachments, only: [:new, :create, :edit, :update]
    post :withdraw, on: :member
    post :publish, on: :member

    # This is for persisted aaib reports
    post :preview, on: :member
  end

  # This is for new aaib reports
  post "aaib-reports/preview" => "aaib_reports#preview", as: "preview_new_aaib_report"

  resources :international_development_funds, except: :destroy, path: "international-development-funds" do
    resources :attachments, controller: :international_development_fund_attachments, only: [:new, :create, :edit, :update]
    post :withdraw, on: :member
    post :publish, on: :member

    # This is for persisted international development funds
    post :preview, on: :member
  end

  # This is for new international development funds
  post "international-development-funds/preview" => "international_development_funds#preview", as: "preview_new_international_development_fund"

  resources :manuals, except: :destroy do
    resources :documents, except: :destroy, path: "sections", controller: "ManualDocuments" do
      resources :attachments, controller: :manual_document_attachments, only: [:new, :create, :edit, :update]

      # This is for persisted manual documents
      post :preview, on: :member
    end

    post :publish, on: :member
  end

  # This is for new manual documents
  post "manuals/:manual_id/sections/preview" => "ManualDocuments#preview", as: "preview_new_manual_document"

  root to: redirect("/manuals")
end
