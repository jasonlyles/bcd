# frozen_string_literal: true

class Update < ApplicationRecord
  mount_uploader :image, ImageUploader, validate_integrity: true
  # attr_accessible :title, :description, :body, :image, :image_cache, :remove_image, :image_align, :created_at, :live, :link

  validates :title, presence: true
  # Taking out the body for now because at first I'm going to keep it simple and just have the updates be 700x250 images.
  # validates :body, :presence => true, :length => {:minimum => 100, :maximum => 2000}

  def self.ransackable_attributes(_auth_object = nil)
    %w[title]
  end

  # Nothing here yet (if ever), but ransack insists I define it.
  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.live_updates
    Update.where("live = 't'").order('created_at desc')
  end
end
