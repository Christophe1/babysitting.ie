require 'resque_scheduler'
require 'resque_scheduler/server'

Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

if defined? Resque
  rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
  rails_env = ENV['RAILS_ENV'] || 'development'

  resque_config = YAML.load_file(rails_root + '/config/resque.yml')
  Resque.redis = resque_config[rails_env]['redis']
  Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")

  Rails.module_eval do
    class << self
      def resque_logger
        @resque_logger ||= begin
          logger = ActiveSupport::BufferedLogger.new(File.join(Rails.root, "log/resque.#{Rails.env}.log"))
          logger.level = ActiveSupport::BufferedLogger.const_get('DEBUG')
          logger
        end
      end
    end
  end
end