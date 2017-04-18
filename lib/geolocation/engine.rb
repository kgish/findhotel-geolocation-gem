module Geolocation
  class Engine < ::Rails::Engine
    isolate_namespace Geolocation

    initializer "geolocation", before: :load_config_initializers do |app|

      # Let engine mount itself.
      Rails.application.routes.append do
        mount Geolocation::Engine, at: "/geolocation"
      end

      # Push all engine migration files into base application migrations list
      config.paths["db/migrate"].expanded.each do |expanded_path|
        Rails.application.config.paths["db/migrate"] << expanded_path
      end
    end

  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.reset
    self.configuration = Configuration.new
  end

  class Configuration
    attr_accessor :enabled
    attr_accessor :file_name
    attr_accessor :upload_dir
    attr_accessor :allow_blank
    attr_accessor :delete_all
    attr_accessor :max_lines

    # Default values
    def initialize
      @enabled = true
      @file_name = 'data_dump.csv'
      @upload_dir = 'uploads'
      @allow_blank = false
      @delete_all = true
      @max_lines = 0
    end
  end
end
