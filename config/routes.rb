SpecialistPublisher::Application.routes.draw do
  resources :specialist_documents, except: :destroy, path: 'specialist-documents' do
    resources :attachments, only: [:new, :create, :edit, :update]
    post :preview, on: :member
    post :withdraw, on: :member
  end

  resources :manuals, except: :destroy do
    resources :documents, except: :destroy, path: 'sections', controller: "ManualDocuments"
  end

  root to: redirect('/specialist-documents')
end
