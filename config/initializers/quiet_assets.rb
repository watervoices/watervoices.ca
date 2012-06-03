# http://stackoverflow.com/questions/6312448/how-to-disable-logging-of-asset-pipeline-sprockets-messages-in-rails-3-1
# https://github.com/rails/rails/pull/4501
# https://github.com/rails/rails/pull/4512

if Rails.env.development?
  #Rails.application.assets.logger = false #Logger.new('/dev/null')
  Rails::Rack::Logger.class_eval do
    def call_with_quiet_assets(env)
      previous_level = Rails.logger.level
      Rails.logger.level = Logger::ERROR if env['PATH_INFO'].index("/assets/") == 0
      call_without_quiet_assets(env).tap do
        Rails.logger.level = previous_level
      end
    end
    alias_method_chain :call, :quiet_assets
  end
end