namespace :dev do
  desc "Switch storage service"
  task :storage, [:service] => :environment do |t, args|
    case args[:service]
    when 's3'
      puts "Switching to S3 storage..."
      # Create or update development.rb with S3 config
      config_path = Rails.root.join('config/environments/development.rb')
      development_config = File.read(config_path)
      development_config.gsub!(/config\.active_storage\.service = :\w+/, 'config.active_storage.service = :amazon')
      File.write(config_path, development_config)
      puts "Updated development.rb to use S3 storage"
      puts "Restart your Rails server for changes to take effect"
    when 'local'
      puts "Switching to local storage..."
      # Create or update development.rb with local config
      config_path = Rails.root.join('config/environments/development.rb')
      development_config = File.read(config_path)
      development_config.gsub!(/config\.active_storage\.service = :\w+/, 'config.active_storage.service = :local')
      File.write(config_path, development_config)
      puts "Updated development.rb to use local storage"
      puts "Restart your Rails server for changes to take effect"
    else
      puts "Please specify 'local' or 's3'"
    end
  end
end 