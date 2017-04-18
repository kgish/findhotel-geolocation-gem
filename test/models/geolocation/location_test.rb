require 'test_helper'

require 'active_support'
require 'active_support/test_case'
require 'minitest/autorun'

# ActiveSupport.test_order = :random

module Geolocation
  class LocationTest < ActiveSupport::TestCase
    def setup
      # Fixture:
      # one: 200.106.141.15,SI,Nepal,DuBuquemouth,-84.87503094689836,7.206435933364332,7823011346
      # two: 160.103.7.140,CZ,Nicaragua,New Neva,-68.31023296602508,-37.62435199624531,7301823115
      @location = Location.create({
        ip_address: '200.106.141.15',
        country_code: 'TL',
        country: 'Saudi Arabia',
        city: 'Gradymouth',
        latitude: -49.16675918861615,
        longitude: -86.05920084416894,
        mystery_value: '2559997162'
      })
    end

    # --- Location Instance --- #
    test 'valid location' do
      assert @location.valid?, 'initial location is valid'
    end

    # --- IP Address --- #
    test 'invalid with illegal ip_address' do
      @location.ip_address = 'illegal_ip_address'
      refute @location.valid?, 'saved location with illegal ip_address'
      assert_not_nil @location.errors[:ip_address], 'validation error for ip_address is present'
    end

    test 'invalid with missing ip_address' do
      @location.ip_address = nil
      refute @location.valid?, 'saved location with missing ip_address'
      assert_not_nil @location.errors[:ip_address], 'validation error for ip_address is present'
    end

    test 'valid with modified legal ip_address' do
      @location.ip_address = '31.185.249.104'
      assert @location.valid?, 'saved location with modified legal ip_address'
      assert_empty @location.errors[:ip_address], 'validation error for ip_address is absent'
    end

    # --- Country Code --- #
    test 'invalid with illegal country_code' do
      @location.country_code = '#$@!'
      refute @location.valid?, 'saved location with illegal country_code'
      assert_not_nil @location.errors[:country_code], 'validation error for country_code is present'
    end

    test 'valid with missing country_code' do
      @location.country_code = nil
      assert @location.valid?, 'saved location with missing country_code'
      assert_not_nil @location.errors[:country_code], 'validation error for country_code is present'
    end

    test 'valid with modified legal country_code' do
      @location.country_code = 'NL'
      assert @location.valid?, 'saved location with modified legal country_code'
      assert_empty @location.errors[:country_code], 'validation error for country_code is absent'
    end

    # --- Country --- #
    test 'invalid with missing country' do
      @location.country = nil
      refute @location.valid?, 'saved location with missing country'
      assert_not_nil @location.errors[:country], 'validation error for country is present'
    end

    test 'valid with modified legal country' do
      @location.country = 'France'
      assert @location.valid?, 'saved location with modified legal country'
      assert_empty @location.errors[:country_code], 'validation error for country is absent'
    end

    # --- City --- #
    test 'valid with missing city' do
      @location.city = nil
      assert @location.valid?, 'saved location with missing city'
      assert_not_nil @location.errors[:country], 'validation error for city is absent'
    end

    test 'valid with modified legal city' do
      @location.city = 'Amsterdam'
      assert @location.valid?, 'saved location with modified legal city'
      assert_empty @location.errors[:city], 'validation error for city is absent'
    end

    # --- Latitude --- #
    test 'invalid with illegal latitude (< -90)' do
      @location.latitude = -91.12345
      refute @location.valid?, 'saved location with illegal latitude'
      assert_not_nil @location.errors[:latitude], 'validation error for latitude is present'
    end

    test 'invalid with illegal latitude (> +90)' do
      @location.latitude = 90.12345
      refute @location.valid?, 'saved location with illegal latitude'
      assert_not_nil @location.errors[:latitude], 'validation error for latitude is present'
    end

    test 'valid with missing latitude' do
      @location.latitude = nil
      assert @location.valid?, 'saved location with missing latitude'
      assert_not_nil @location.errors[:latitude], 'validation error for latitude is present'
    end

    test 'valid with modified legal latitude' do
      @location.latitude = -68.31023296602508
      assert @location.valid?, 'saved location with modified legal latitude'
      assert_empty @location.errors[:latitude], 'validation error for latitude is absent'
    end

    # --- Longitude --- #
    test 'invalid with illegal longitude (< -180)' do
      @location.longitude = -185.12345
      refute @location.valid?, 'saved location with illegal longitude'
      assert_not_nil @location.errors[:longitude], 'validation error for longitude is present'
    end

    test 'invalid with illegal longitude (> +180)' do
      @location.longitude = 190.12345
      refute @location.valid?, 'saved location with illegal longitude'
      assert_not_nil @location.errors[:longitude], 'validation error for longitude is present'
    end

    test 'valid with missing longitude' do
      @location.longitude = nil
      assert @location.valid?, 'saved location with missing longitude'
      assert_not_nil @location.errors[:longitude], 'validation error for longitude is present'
    end

    test 'valid with modified legal longitude' do
      @location.longitude = 7.206435933364332
      assert @location.valid?, 'saved location with modified legal longitude'
      assert_empty @location.errors[:longitude], 'validation error for longitude is absent'
    end

    # --- Mystery Value --- #
    test 'valid with missing mystery_value' do
      @location.mystery_value = nil
      assert @location.valid?, 'saved location with missing mystery_value'
      assert_empty @location.errors[:mystery_value], 'validation error for mystery_value is present'
    end

    # --- Duplicates --- #
    test 'invalid with duplicate country_code, country and city' do
      @location.country_code = 'SI'
      @location.country = 'Nepal'
      @location.city = 'DuBuquemouth'
      refute @location.valid?, 'saved location with duplicated country_code, country and city'
      assert_not_nil @location.errors[:city], 'validation error for city is present'
    end

  end
end
