require 'csv'

require_dependency "geolocation/application_controller"

module Geolocation
  class LocationsController < ApplicationController
    # TODO: implement authenticatio using apikey
    skip_before_action :verify_authenticity_token
    before_action :set_location, only: [:show]

    # GET /locations
    def index
      @locations = Location.all
    end

    # GET /locations/1
    def show
    end

    def ip_address
      begin
        location = Location.find_by(ip_address: params[:id])
        if location
          render json: { location: location }
        else
          render json: { errors: ['404 Not found'] }, status: :not_found
        end
      rescue ActiveRecord::StatementInvalid => invalid
        render json: { errors: ['422 Invalid IP Address'] }, status: :unprocessable_entity
      end
    end

    # POST /import_data.json
    def import_data

      start = Time.now

      # TODO: make configurable
      data_dump_csv = "#{Rails.root}/../../uploads/data_dump_small.csv"

      Location.delete_all

      line = 0
      nok = 0
      errors = []
      CSV.foreach(data_dump_csv, headers: true) do |row|
        line = line + 1
        location_hash = row.to_hash
        begin
          Location.create!(location_hash)
        rescue ActiveRecord::RecordInvalid => invalid
          nok = nok + 1
          errors.push({
            line: line,
            values: location_hash.values.join(','),
            messages: invalid.record.errors.messages}
          )
        end
      end

      # Statistics
      now = Time.now
      elapsed = now - start

      render json: {
        import_data: {
          dumpfile: data_dump_csv,
          records: {
              total: line,
              ok: line - nok,
              nok: nok,
              errors: errors
          },
          stopwatch: {
              started: start.to_s,
              finished: now.to_s,
              elapsed: elapsed.to_s
          }
        }
      }
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_location
        @location = Location.find(params[:id])
      end
  end
end
