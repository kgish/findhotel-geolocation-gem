module Geolocation
  class LatitudeValidator < ActiveModel::Validator
    def validate(record)
      unless !record.latitude.nil? && record.latitude > -90 && record.latitude < 90
        record.errors[:latitude] << 'must lie between -90 and +90'
      end
    end
  end

  class LongitudeValidator < ActiveModel::Validator
    def validate(record)
      unless !record.longitude.nil? && record.longitude > -180 && record.longitude < 180
        record.errors[:longitude] << 'must lie between -180 and +180'
      end
    end
  end

  class Location < ApplicationRecord
    include ActiveModel::Validations
    validates_with LatitudeValidator
    validates_with LongitudeValidator

    validates :ip_address, :country_code, :country, :city, :latitude, :longitude, :mystery_value, presence: true
    validates :country_code, format: { :with => /\A[A-Z][A-Z]\z/i, message: 'only allows two letters' }
    validates :city, uniqueness: {scope: [:country_code, :country]}
  end
end
