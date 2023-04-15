# frozen_string_literal: true

class EmailCampaign < ApplicationRecord
  audited except: %i[created_at updated_at]
  include ActiveModel::Serialization

  before_create :generate_guid
  mount_uploader :image, ImageUploader, validate_integrity: true
  # attr_accessible :click_throughs, :description, :image, :image_cache, :remove_image, :message,
  # :subject, :emails_sent, :guid, :redirect_link

  validates_presence_of :description, :subject

  def attributes
    super.merge(
      {
        'image_medium_url' => image&.medium&.url
      }
    )
  end

  def generate_guid
    self.guid = SecureRandom.hex(20)
  end

  def effectiveness_ratio
    (click_throughs / emails_sent.to_f) * 100
  end

  def destroy
    if emails_sent.positive?
      nil
    else
      super
    end
  end
end
