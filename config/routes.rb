SpecialistPublisher::Application.routes.draw do
  resources :specialist_documents, except: [:show], path: 'specialist-documents' do
    resources :attachments, only: [:new, :edit, :create]
    post :preview, on: :member
  end

  root to: redirect('/specialist-documents')
end
