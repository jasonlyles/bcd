class Update < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  attr_accessible :title, :description, :body, :image, :image_cache, :remove_image, :image_align, :created_at, :live, :link

  validates :title, :presence => true
  #Taking out the body for now because at first I'm going to keep it simple and just have the updates be 700x250 images.
  #validates :body, :presence => true, :length => {:minimum => 100, :maximum => 2000}

  def self.live_updates
    Update.where("live = 't'").order("created_at desc")
  end

end
