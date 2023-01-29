Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.credentials.redis.url, network_timeout: 5 }
  # If I get Honeybadger set up, specify it here:
  # config.error_handlers << proc {|ex,ctx_hash| MyErrorService.notify(ex, ctx_hash) }
  config.on(:startup) do
    schedule_file = 'config/sidekiq_schedule.yml'

    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.credentials.redis.url, network_timeout: 5 }
end

Sidekiq.default_job_options = { 'backtrace' => 20 }
