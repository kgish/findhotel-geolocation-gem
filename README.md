# Geolocation
Short description and motivation.

In the `app/controllers/geolocation/application_controller.rb` file I've defined the `render_json_error` method which can be inherited all controllers extending it:

```ruby
module Geolocation
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def render_json_error(message, status)
      render json: { errors: [message] }, status: status
    end
  end
end
```

In the `app/controllers/geolocation/locations_controller.rb` file:

```ruby
module Geolocation
  class LocationsController < ApplicationController

    # GET /locations
    def index
      @locations = Location.all
    end

    # GET /locations/1
    def show
    end

    # GET /ip_address/:id
    def ip_address
    end

    # POST /import_data
    def import_data
    end
 end
end
```

The `import_data` will parse the CSV data file and insert the valid non-duplicate entries into the data store, and when completed returns a complete report in json format:

```json
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
```

where `errors` is a collection of rejected entries looking like this:

```json
{
    line: line,
    values: location_hash.values.join(','),
    messages: e.record.errors.messages
}
```

## Migration

```
bin/rails g migration ....
```

To produce the migration script:

```
class CreateGeolocationLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :geolocation_locations do |t|
      t.inet :ip_address
      t.string :country_code
      t.string :country
      t.string :city
      t.float :latitude
      t.float :longitude
      t.integer :mystery_value, limit: 8
    end
    add_index :geolocation_locations, :ip_address
    add_index :geolocation_locations, [:country_code, :country, :city], unique: true, name: 'index_geolocation_locations_on_cccc'
  end
end
```

Type `inet` is supported by postgresql.

The 'ip_address` column is indexed to speed up queries since the IP address is used for searching the database.

Also I index on a unique multi-column contraint for country_code, country and city assuming that the combination of these three values must be unique (first come first serve during the data import).

Had to implement a user-defined name `index_geolocation_locations_cccc` for the geolocation_locations index in order to avoid the name too long error.

## Model Validations

In the `app/models/geolocation/location.rb` file:

```
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
```

In the `app/lib/geolocation/engine.rb` file, I have the gem push migrations to the application migrations list:

```
module Geolocation
  class Engine < ::Rails::Engine
    isolate_namespace Geolocation

    initializer "geolocation", before: :load_config_initializers do |app|

      ...

      # Push all engine migration files into base application migrations list
      config.paths["db/migrate"].expanded.each do |expanded_path|
        Rails.application.config.paths["db/migrate"] << expanded_path
      end
    end

  end
```

In the `app/config/routes.rb` file:

```
Geolocation::Engine.routes.draw do
  resources :locations, only: ['index', 'show']
  get '/ip_address/:ip_address' => 'locations#ip_address', as: 'ip_address', constraints: { :ip_address => /[^\/]+/ }
  post '/import_data' => 'locations#import_data'
end
```

Notice how the `constraints` modifier is used in order to allow dots (.) to appear in the passed `:id` parameter.

I've also explicityly named the GET /ip_address rout with an as `ip_address` so that I can use `ip_address_url` in the tests.

In the `app/lib/geolocation/engine.rb` file, I have the gem mount itself in the application routes:

```
module Geolocation
  class Engine < ::Rails::Engine
    isolate_namespace Geolocation

    initializer "geolocation", before: :load_config_initializers do |app|

      # Let engine mount itself.
      Rails.application.routes.append do
        mount Geolocation::Engine, at: "/geolocation"
      end

      ...

    end
  end
end
```

## Configuration

In the `app/lib/geolocation/engine.rb` file, I define a `configuration` accessor like this:

```ruby
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
```

In the application, this values can be modified by including an `app/config/initializer/geolocation.rb` file that looks like this (defaults listed):

```ruby
if defined? Geolocation
  Geolocation.configure do |config|
    config.enabled = true
    config.file_name = 'data_dump.csv'
    config.upload_dir = 'uploads'
    config.allow_blank = true
    config.delete_all = true
    config.max_lines = 0
  end
end
```

Where:

* `enabled` means on/off (not yet implemented)
* `file_name` is the name of the import data file
* `upload_dir` is the directory where the file is located
* `allow_blank` means that country_code, city, latitude and/or longitude may be empty (not yet implemented)
* `delete_all` means that the location table is emptied before the import starts
* `max_lines` means limit the import to this number of lines

## Installation

```shell
git clone https://github.com/kgish/findhotel-geolocation-gem.git ~/projects
```

Add this line to your application's Gemfile:

```ruby
gem 'geolocation', path: 'plugins/geolocation'
```

Finally, you'll need to include the new gem in the bundle:

```shell
bundle install
```

## Testing

I use good old Minitest for verifying that the gem is working properly, namely:

```
cd test/dummy
bin/rails app:test
```

The following tests are present:

* location controller (index, show, ip_address and import_data) for :success, :not_found and :unprocessable_entity
* configuration settings (all values)
* location model (valid? and errors) for :ip_address, :country_code, :country, :city, :latitude, :longitude, :mystery_value and unique constraints


## Heroku App



## Author

Kiffin Gish \< kiffin.gish@planet.nl \>

\- You're never too old to learn new stuff.


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
