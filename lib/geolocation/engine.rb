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

  class Configuration
    attr_accessor :enabled
    attr_accessor :uploads_dir
    attr_accessor :data_dump_csv

    def initialize
      @enabled = true
      @uploads_dir = 'uploads'
      @data_dump_csv = 'data_dump.csv'
    end
  end
end
