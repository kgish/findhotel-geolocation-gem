require 'test_helper'

module Geolocation
  class ConfigurationTest < ActionDispatch::IntegrationTest

    test "should have default values at startup" do
      Geolocation.configure do |config|
        assert(config.enabled == true)
        assert(config.file_name == 'data_dump.csv')
        assert(config.upload_dir == 'uploads')
        assert(config.allow_blank == false)
        assert(config.delete_all == true)
        assert(config.max_lines == 0)
      end
    end

    test "should allow values to be changed" do
      Geolocation.configure do |config|
        config.enabled = false
        config.file_name = 'data_dump_other.csv'
        config.upload_dir = 'elsewhere'
        config.allow_blank = true
        config.delete_all = false
        config.max_lines = 998
      end

      Geolocation.configure do |config|
        assert(config.enabled == false)
        assert(config.file_name == 'data_dump_other.csv')
        assert(config.upload_dir == 'elsewhere')
        assert(config.allow_blank == true)
        assert(config.delete_all == false)
        assert(config.max_lines == 998)
      end
    end

    teardown do
      Geolocation.reset
    end

  end
end
