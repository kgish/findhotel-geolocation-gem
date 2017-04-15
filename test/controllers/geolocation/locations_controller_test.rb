require 'test_helper'

module Geolocation
  class LocationsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @location = geolocation_locations(:one)
    end

    test "should get index" do
      get locations_url
      assert_response :success
    end

    test "should show location" do
      get location_url(@location)
      assert_response :success
    end

  end
end
