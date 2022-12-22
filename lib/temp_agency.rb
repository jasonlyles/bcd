# frozen_string_literal: true

# An auto-scaler for Heroku workers, which borrows heavily from the example here:
# http://verboselogging.com/2010/07/30/auto-scale-your-resque-workers-on-heroku
# I mostly just tweaked it to use the platform-api gem and be able to handle different queues
module TempAgency
  class Scaler
    attr_accessor :ps_name, :queue_name

    def initialize(args)
      args.each { |key, value| eval("@#{key}=value") }
      @ps_name = @queue_name
      @heroku = PlatformAPI.connect_oauth(HerokuOauthToken.retrieve_token)
    end

    def workers
      workers = @heroku.formation.info(ENV['APP_NAME'], @ps_name)
      Rails.logger.debug("ACTIVE WORKERS FOR #{@ps_name}: #{workers['quantity']}")
      workers['quantity']
    end

    def workers=(qty)
      Rails.logger.debug("SETTING WORKERS TO: #{qty} on PS #{@ps_name}")
      @heroku.formation.update(ENV['APP_NAME'], @ps_name, { 'quantity' => qty, 'size' => 'Standard-1X' })
    end

    def job_count
      Rails.logger.debug("QUEUE NAME: #{@queue_name}")
      Resque.size(@queue_name)
    end
  end

  def after_perform_scale_down(*args)
    return if Rails.env == 'development'

    Rails.logger.debug('SCALING DOWN')
    @scaler = if queue_name.is_a?(Symbol)
                Scaler.new(queue_name: queue_name.to_s)
              else
                Scaler.new(queue_name: 'mailer')
              end
    @scaler.workers = 0 if @scaler.job_count.zero?
  end

  def after_enqueue_scale_up(*args)
    return if Rails.env == 'development'

    Rails.logger.debug("SCALING UP, QUEUE NAME CLASS: #{queue_name.class}")
    # Hack, while I get something sorted:
    @scaler = if queue_name.is_a?(Symbol)
                Scaler.new(queue_name: queue_name.to_s)
              else
                Scaler.new(queue_name: 'mailer')
              end
    @scaler.workers = 1 if @scaler.job_count.positive? && @scaler.workers.zero?
  end
end
