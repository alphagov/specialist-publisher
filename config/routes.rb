SpecialistPublisher::Application.routes.draw do
  resources :specialist_documents, except: [:show], path: 'specialist-documents' do
    resources :attachments, only: [:new, :edit, :create]
  end
  post '/specialist-documents/preview' => 'specialist-documents#preview'

  root to: redirect('/specialist-documents')
end
