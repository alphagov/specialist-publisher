SpecialistPublisher::Application.routes.draw do
  resources :specialist_documents, except: [:show], path: 'specialist-documents'

  root to: redirect('/specialist-documents')
end
