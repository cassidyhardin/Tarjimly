Rails.application.routes.draw do

  #Login
  post '/auth' => 'auth#authenticate', :as => 'validate_login'
  get '/auth' => 'auth#logout', :as => 'logout'
  get ‘/auth/facebook/callback’ => 'auth#authenticateFB'



  #User Pages
  get '/requests' => 'requests#index', :as => 'requests'
  get '/requests/new' => 'requests#new', :as => 'new_request'
  get '/requests/:request_id' => 'requests#show', :as => 'request'
  post '/requests' => 'requests#create', :as => 'create_request'
  delete '/requests/:request_id' => 'requests#delete', :as => 'delete_request'

  #Translator Pages
  get '/claims' => 'claims#index', :as => 'claims'
  get '/claims/:claim_id' => 'claims#show', :as => 'claim'
  post '/claims' => 'claims#create', :as => 'create_claim'
  delete '/claims/:claim_id' => 'claims#delete', :as => 'delete_claim'
  patch '/claims/:claim_id' => 'claims#complete', :as => 'complete_claim'
  
  ## Translator -> View All Requests
  get '/translators/requests' => 'claims#requests', :as => 'view_requests'
  get '/translators/requests/:request_id' => 'claims#preview', :as => 'preview_request'


  root 'application#index'

end
