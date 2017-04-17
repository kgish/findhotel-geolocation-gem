Geolocation.configure do |config|
  config.enabled = true
  config.file_name = 'data_dump.csv'
  config.upload_dir = 'uploads'
  config.allow_blank = false
  config.delete_all = true
  config.max_lines =
end