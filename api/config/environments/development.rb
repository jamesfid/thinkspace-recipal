Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # ################## #
  # ### THINKSPACE ### #
  # ################## #
  # Rack CORS configuration
  config.middleware.insert_before 0, 'Rack::Cors' do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :put, :delete, :post, :options]
    end
  end
  # Paperclip Storage
  config.paperclip_defaults = {
     storage: :s3,
       s3_credentials: {
         bucket: Rails.application.secrets.aws['s3']['paperclip']['bucket_name'],
         access_key_id: Rails.application.secrets.aws['s3']['paperclip']['access_key'],
         secret_access_key: Rails.application.secrets.aws['s3']['paperclip']['secret_access_key']
       },
   s3_protocol: :https
  }

  # SMTP
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    :address => "localhost",
    :port => 1025,
    :domain => "localhost" }

  Slim::Engine.options[:pretty] = true

  # Controller caching
  config.action_controller.perform_caching = true
  config.action_controller.cache_store = :memory_store

  # NewRelic RPM
  ENV['NEW_RELIC_DEVELOPER_MODE'] = 'true'
  ENV['NEW_RELIC_MONITOR_MODE']   = 'false'
  ENV['NEW_RELIC_LOG_LEVEL']      = 'info'
  ENV['NEW_RELIC_APP_NAME']       = 'dev_app'
  ENV['NEW_RELIC_CAPTURE_PARAMS'] = 'true'
  begin
    require 'newrelic_rpm'
  rescue LoadError
  else
    NewRelic::Agent.manual_start
  end

  config.after_initialize do
    # ### Set Paperclip to use local file storage if S3 secrets not set.
    paperclip_access_key = Rails.application.secrets.dig('s3', 'paperclip', 'access_key')
    if paperclip_access_key.blank? || paperclip_access_key.match('-HERE')
      Paperclip::Attachment.default_options.merge!(storage: :filesystem, path: ':dev_override_path/:filename', url: ':url_path/:filename', use_timestamp: false)
      Paperclip::Interpolations.send :alias_method, :original_artifact_path, :artifact_path
      Paperclip.interpolates :artifact_path do |attachment, style|
        result = original_artifact_path(attachment, style)
        'public/paperclip/' + result
      end
      Paperclip.interpolates :dev_override_path do |attachment, style|
        result = "#{attachment.instance.class.name.underscore}/#{attachment.instance.id}"
        'public/paperclip/' + result
      end
      Paperclip.interpolates :url_path do |attachment, style|
        result = attachment.instance.is_a?(Thinkspace::Artifact::File) ? artifact_path(attachment, style) : dev_override_path(attachment, style)
      end
    end
    # # ### Trigger the totem associations to create the model associations and serializers
    # # ### to speed up the initial login (do not do when running rails c or a rake task).
    # unless (defined?(::Rails::Console) || File.split($0).last == 'rake')
    #    Thinkspace::Common::User.first
    # end
  end


end
