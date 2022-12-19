class BackendNotification < ActiveRecord::Base
  belongs_to :dismissed_by, class_name: 'Radmin'

  validates :message, presence: true

  scope :active_notifications, -> { where('dismissed_by_id IS NULL').order(created_at: :asc) }
end
