Geolocation::Engine.routes.draw do
  resources :locations, only: ['index', 'show']
  get '/ip_address/:ip_address' => 'locations#ip_address', constraints: { :ip_address => /[^\/]+/ }
  post '/import_data' => 'locations#import_data'
end
