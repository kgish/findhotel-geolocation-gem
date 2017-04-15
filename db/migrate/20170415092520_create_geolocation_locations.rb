class CreateGeolocationLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :geolocation_locations do |t|
      t.inet :ip_address
      t.string :country_code
      t.string :country
      t.string :city
      t.float :latitude
      t.float :longitude
      t.integer :mystery_value

      t.timestamps
    end
    add_index :geolocation_locations, :ip_address
  end
end
