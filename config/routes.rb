SpecialistPublisher::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails::Engine)

  resources :specialist_documents, except: :destroy, path: 'specialist-documents' do
    resources :attachments, only: [:new, :create, :edit, :update]
    post :preview, on: :member
    post :withdraw, on: :member
    post :publish, on: :member
  end

  resources :manuals, except: :destroy do
    resources :documents, except: :destroy, path: 'sections', controller: "ManualDocuments" do
      resources :attachments, controller: "ManualDocumentsAttachments", only: [:new, :create, :edit, :update]
      post :preview, on: :member
    end
  end

  root to: redirect('/manuals')
end
