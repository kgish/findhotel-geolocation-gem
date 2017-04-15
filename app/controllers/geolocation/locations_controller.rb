require 'csv'

require_dependency "geolocation/application_controller"

module Geolocation
  class LocationsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_location, only: [:show]

    # GET /locations
    def index
      @locations = Location.all
    end

    # GET /locations/1
    def show
    end

    # POST /import_data.json
    def import_data

      start = Time.now

      data_dump_csv = "#{Rails.root}/../../uploads/data_dump.csv"

      Location.delete_all

      data = CSV.read(data_dump_csv)
      header = data.shift
      data.each_with_index do |rec, index|
      end

      # Statistics
      now = Time.now
      elapsed = now - start

      render json: { import_data: {
          dumpfile: data_dump_csv,
          header: header.inspect,
          records: data.count,
          stopwatch: {
              started: start.to_s,
              finished: now.to_s,
              elapsed: elapsed.to_s
          }
      } }
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_location
        @location = Location.find(params[:id])
      end
  end
end
