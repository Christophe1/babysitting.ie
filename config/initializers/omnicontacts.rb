require "omnicontacts"

config_path = Rails.root.join("config", "omnicontacts.yml")
if File.exists?(config_path)
  config = YAML.load_file(config_path)[Rails.env]
else
  Rails.logger.warn("Could not find omnicontacts.yml in config directory.")
end

Rails.application.middleware.use OmniContacts::Builder do
  %w(gmail yahoo hotmail).each do |social|
    importer social.to_sym, config[social]['app_id'], config[social]['app_secret'], { :max_results => 999 }
  end
end
