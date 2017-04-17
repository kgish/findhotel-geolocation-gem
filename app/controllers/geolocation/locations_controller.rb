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

      # Get necessary configuration parameters, overruled by query parameters if present.
      config = Geolocation.configuration
      file_name = params[:file_name] || config.file_name
      upload_dir = params[:upload_dir] || config.upload_dir

      if params[:allow_blank]
        allow_blank = params[:allow_blank] == 'true'
      else
        allow_blank = config.allow_blank
      end

      if params[:delete_all]
        delete_all = params[:delete_all] == 'true'
      else
        delete_all = config.delete_all
      end

      if params[:max_lines]
        max_lines = params[:max_lines]
      else
        max_lines = config.max_lines
      end
      max_lines = max_lines.to_i

      file_name_path = "#{upload_dir}/#{file_name}"
      full_path = "#{Rails.root}/#{file_name_path}"

      Location.delete_all if delete_all

      # Stopwatch for this transaction
      start = Time.now

      line = 0
      nok = 0
      errors = []

      begin
        CSV.foreach(full_path, headers: true) do |row|
          line = line + 1
          break if max_lines != 0 && line > max_lines
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
                file_name: file_name,
                upload_dir: upload_dir,
                allow_blank: allow_blank,
                delete_all: delete_all,
                max_lines: max_lines,
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
