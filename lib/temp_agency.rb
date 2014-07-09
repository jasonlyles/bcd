# An auto-scaler for Heroku workers, which borrows heavily from the example here:
# http://verboselogging.com/2010/07/30/auto-scale-your-resque-workers-on-heroku
# I mostly just tweaked it to use the heroku-api gem and be able to handle different queues
module TempAgency
  class Scaler
    @@heroku = Heroku::API.new(api_key: ENV['HEROKU_API_KEY'])

    attr_accessor :ps_name, :queue_name
    def initialize(args)
      args.each{|key,value| eval("@#{key}=value")}
      @ps_name = @queue_name
      self
    end

    def workers
      workers = @@heroku.get_ps(ENV['APP_NAME']).body.select { |ps| ps["process"] =~ /#{@ps_name}/ }
      #puts "ACTIVE WORKERS FOR #{@ps_name}: #{workers.size}"
      workers.size
    end

    def workers=(qty)
      #puts "SETTING WORKERS TO: #{qty} on PS #{@ps_name}"
      @@heroku.post_ps_scale(ENV['APP_NAME'], @ps_name, qty)
    end

    def job_count
      #puts "QUEUE NAME: #{@queue_name}"
      Resque.size(@queue_name)
    end
  end

  def after_perform_scale_down(*args)
    unless Rails.env == "development"
      #puts "SCALING DOWN"
      @scaler = Scaler.new(queue_name: queue.to_s)
      @scaler.workers = 0 if @scaler.job_count.zero?
    end
  end

  def after_enqueue_scale_up(*args)
    unless Rails.env == "development"
      #puts "SCALING UP"
      @scaler = Scaler.new(queue_name: queue.to_s)
      @scaler.workers = 1 if @scaler.job_count > 0 && @scaler.workers == 0
    end
  end

end