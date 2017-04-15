Geolocation::Engine.routes.draw do
  # resources :locations, only: ['index', 'show']
  get '/ip_address/:id' => 'locations#ip_address'
  post '/import_data' => 'locations#import_data'
end
