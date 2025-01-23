# frozen_string_literal: true

class Setting < ApplicationRecord
  class InvalidSetting < StandardError; end

  validates_presence_of %i[name value description]
  validates :name, uniqueness: { case_sensitive: true }

  def self.method_missing(method_name, *args, &block)
    if method_name.to_s.match(/.*_value$/)
      setting_name = method_name.to_s.gsub('_value', '')
      setting = Setting.find_by(name: setting_name)
    else
      super
    end

    raise InvalidSetting, "Settings record '#{setting_name}' does not exist" if setting.blank?

    setting.value
  end

  def self.respond_to_missing?(method_name, include_private = false)
    method_name.to_s.match(/.*_value$/) || super
  end
end
