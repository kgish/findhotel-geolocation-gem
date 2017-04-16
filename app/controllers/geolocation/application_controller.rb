module Geolocation
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def render_json_error(message, status)
      render json: { errors: [message] }, status: status
    end
  end
end
