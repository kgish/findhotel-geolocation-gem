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

      t.timestamps
    end
    add_index :geolocation_locations, :ip_address
    add_index :geolocation_locations, [:country_code, :country, :city], unique: true, name: 'index_geolocation_locations_on_cccc'
  end
end
