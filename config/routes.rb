SpecialistPublisher::Application.routes.draw do
  resources :specialist_documents, path: 'specialist-documents' do
    resources :attachments, only: [:new, :create, :edit, :update]
    post :preview, on: :member
    post :withdraw, on: :member
  end

  root to: redirect('/specialist-documents')
end
