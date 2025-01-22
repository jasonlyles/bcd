# frozen_string_literal: true

class Feature < ApplicationRecord
  validates_presence_of %i[name description]
  validates :name, uniqueness: { case_sensitive: true }

  def self.method_missing(method_name, *args, &block)
    if method_name.to_s.match(/.*_enabled?/)
      feature_name = method_name.to_s.gsub('_enabled?', '')
      feature = Feature.find_by(name: feature_name)

      # Prevent future features from breaking code before the record is in the database
      return false unless feature.present?

      feature.enabled?
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    method_name.to_s.match(/.*_enabled?/) || super
  end

  def enable!
    update(enabled: true)
  end

  def disable!
    update(enabled: false)
  end
end
