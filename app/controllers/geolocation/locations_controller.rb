require 'csv'

require_dependency "geolocation/application_controller"

module Geolocation
  class LocationsController < ApplicationController
    # TODO: implement authentication using apikey
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
        location = Location.find_by(ip_address: params[:ip_address])
        if location
          render json: { location: location }
        else
          render_json_error('404 Not Found', :not_found)
        end
      rescue ActiveRecord::StatementInvalid
        render_json_error('422 Invalid IP Address', :unprocessable_entity)
      end
    end

    # POST /import_data
    def import_data

      # Get necessary configuration parameters
      config = Geolocation.configuration
      data_dump_csv = "#{config.uploads_dir}/#{config.data_dump_csv}"
      data_dump_path = "#{Rails.root}/#{data_dump_csv}"

      # TODO: allow missing city and latlong
      allow_missing_city = config.allow_missing_city
      allow_missing_latlong = config.allow_missing_latlong

      Location.delete_all

      # Stopwatch for this transaction
      start = Time.now

      line = 0
      nok = 0
      errors = []

      begin
        CSV.foreach(data_dump_path, headers: true) do |row|
          line = line + 1
          location_hash = row.to_hash
          begin
            Location.create!(location_hash)
          rescue ActiveRecord::RecordInvalid => e
            nok = nok + 1
            errors.push({
              line: line,
              values: location_hash.values.join(','),
              messages: e.record.errors.messages
            })
          end
        end

        # Statistics
        now = Time.now
        elapsed = now - start

        render json: {
            import_data: {
                dumpfile: data_dump_csv,
                stopwatch: {
                    started: start.to_s,
                    finished: now.to_s,
                    elapsed: elapsed.to_s
                },
                records: {
                    total: line,
                    ok: line - nok,
                    nok: nok,
                    errors: errors
                }
            }
        }
      rescue Errno::ENOENT
        render_json_error('422 No such file or directory', :unprocessable_entity)
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_location
        @location = Location.find(params[:id])
      end
  end
end
