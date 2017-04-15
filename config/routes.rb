Geolocation::Engine.routes.draw do
  resources :locations, only: ['index', 'show']
  post '/import_data' => 'locations#import_data'
end
