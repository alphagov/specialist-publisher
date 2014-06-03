SpecialistPublisher::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails::Engine)

  resources :specialist_documents, except: :destroy, path: 'specialist-documents' do
    resources :attachments, only: [:new, :create, :edit, :update]
    post :withdraw, on: :member
    post :publish, on: :member

    # This is for persisted documents
    post :preview, on: :member
  end

  # This is for new documents
  post 'specialist-documents/preview' => 'specialist_documents#preview', as: 'preview_new_specialist_document'

  resources :manuals, except: :destroy do
    resources :documents, except: :destroy, path: 'sections', controller: "ManualDocuments" do
      resources :attachments, controller: "ManualDocumentsAttachments", only: [:new, :create, :edit, :update]

      # This is for persisted manual documents
      post :preview, on: :member
    end

    post :publish, on: :member
  end

  # This is for new manual documents
  post 'manuals/:manual_id/sections/preview' => 'ManualDocuments#preview', as: 'preview_new_manual_document'

  root to: redirect('/manuals')
end
