module Geolocation
  class LatitudeValidator < ActiveModel::Validator
    def validate(record)
      if !record.latitude.blank? && (record.latitude < -90 || record.latitude > 90)
        record.errors[:latitude] << 'must lie between -90 and +90'
      end
    end
  end

  class LongitudeValidator < ActiveModel::Validator
    def validate(record)
      if !record.longitude.blank? && (record.longitude < -180 || record.longitude > 180)
        record.errors[:longitude] << 'must lie between -180 and +180'
      end
    end
  end

  class Location < ApplicationRecord
    include ActiveModel::Validations
    validates_with LatitudeValidator
    validates_with LongitudeValidator

    validates :ip_address, :country, presence: true
    validates :latitude, :longitude, :mystery_value, presence: true, allow_blank: true
    validates :country_code, format: { :with => /\A[A-Z][A-Z]\z/i, message: 'only allows two letters' }, allow_blank: true
    validates :city, uniqueness: {scope: [:country_code, :country]}, allow_blank: true
  end
end
