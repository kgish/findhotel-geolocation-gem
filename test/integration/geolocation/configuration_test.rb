require 'test_helper'

module Geolocation
  class ConfigurationTest < ActionDispatch::IntegrationTest

    test "should have default values at startup" do
      Geolocation.configure do |config|
        assert(config.enabled == true)
        assert(config.uploads_dir == 'uploads')
        assert(config.data_dump_csv == 'data_dump.csv')
        assert(config.allow_missing_city == false)
        assert(config.allow_missing_latlong == false)
      end
    end

    test "should allow values to be changed" do
      Geolocation.configure do |config|
        config.enabled = false
        config.uploads_dir = 'elsewhere'
        config.data_dump_csv = 'data_dump_other.csv'
        config.allow_missing_city = true
        config.allow_missing_latlong = true
      end

      Geolocation.configure do |config|
        assert(config.enabled == false)
        assert(config.uploads_dir == 'elsewhere')
        assert(config.data_dump_csv == 'data_dump_other.csv')
        assert(config.allow_missing_city == true)
        assert(config.allow_missing_latlong == true)
      end
    end

    teardown do
      Geolocation.reset
    end

  end
end
