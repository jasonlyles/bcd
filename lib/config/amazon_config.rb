require 'active_support/configurable'

module AmazonConfig
  def self.configure(&block)
    yield @config ||= AmazonConfig::Configuration.new
  end

  def self.config
    @config ||= {}
  end

  def self.config=(hash)
    @config=hash
  end

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :instruction_bucket
    config_accessor :image_bucket
    config_accessor :access_key
    config_accessor :secret
  end
end