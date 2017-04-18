require 'test_helper'

module Geolocation
  class LocationsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @location = geolocation_locations(:one)
    end

    # --- INDEX --- #
    test "should get index" do
      get locations_url
      assert_response :success
    end

    # --- SHOW --- #
    test "should show location" do
      get location_url(@location)
      assert_response :success
    end

    # --- IP ADDRESS --- #
    test "should get ip_address" do
      get ip_address_url @location.ip_address
      assert_response :success
    end

    test "should return error on invalid ip_address" do
      get ip_address_url '123456'
      assert_response :unprocessable_entity
    end

    test "should return 404 on ip_address not found" do
      get ip_address_url '200.166.141.15'
      assert_response :not_found
    end

    # --- IMPORT DATA --- #
    test "should post import_data" do
      post import_data_url params: { file_name: 'data_dump_test.csv' }
      assert_response :success
    end

    test "should return error on invalid file_name" do
      post import_data_url params: { file_name: 'doesnt_exist.csv' }
      assert_response :unprocessable_entity
    end

  end
end
