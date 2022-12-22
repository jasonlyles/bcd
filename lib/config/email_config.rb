# frozen_string_literal: true

require 'active_support/configurable'

module EmailConfig
  def self.configure(&block)
    yield @config ||= EmailConfig::Configuration.new
  end

  def self.config
    @config ||= {}
  end

  def self.config=(hash)
    @config = hash
  end

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :error_notification
    config_accessor :physical_order
    config_accessor :contact
  end
end
