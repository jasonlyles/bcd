# frozen_string_literal: true

class AdvertisingCampaign < ApplicationRecord
  belongs_to :partner

  # attr_accessible :campaign_live, :description, :partner_id, :reference_code

  validates :partner_id, presence: true
  validates :description, presence: true
  validates :reference_code, presence: true, length: { minimum: 10, maximum: 10 }, uniqueness: true

  # rubocop:disable Naming/PredicateName
  def has_users?
    User.where(['referrer_code = ?', reference_code]).exists?
  end
  # rubocop:enable Naming/PredicateName

  def destroy
    if has_users?
      # switch campaign_live flag to 'f', which will 'deactivate' the advertising campaign, but leaves it in the database
      # for reporting purposes
      self.campaign_live = 'f'
      save
    else
      super
    end
  end

  def user_count
    User.where(['referrer_code=?', reference_code]).count
  end
end
