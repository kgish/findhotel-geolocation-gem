require 'csv'

namespace :geolocation do
  desc "Geolocation import data"
    task :import_data do
      puts "Called :geolocation"

      start = Time.now

      data = CSV.read('data_dump.csv')
      puts data[0].inspect
      puts "Read #{data.count-1} lines!"

      # Statistics
      now = Time.now
      elapsed = now - start

      puts
      puts 'Started:      ' + start.to_s
      puts 'Now:          ' + now.to_s
      puts 'Elapsed time: ' +  elapsed.to_s + ' seconds'

  end
end