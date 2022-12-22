# frozen_string_literal: true

class Partner < ApplicationRecord
  has_many :advertising_campaigns, :dependent => :destroy

  # attr_accessible :contact, :name, :url

  # I don't want to allow a partner who we've set up an advertising campaign for (that's actually been used) to be
  # deleted. This record should be held on to for historical value, and also because there is a user with a referrer_code
  # that references an advertising campaign that belongs to this partner. Allowing deletion of that partner would leave
  # broken relationships
  def has_advert_campaign_thats_been_used?
    has_been_used = false
    if advertising_campaigns.count.positive?
      advertising_campaigns.each do |ac|
        if ac.has_users? == true
          has_been_used = true
          break
        end
      end
    else
      has_been_used = false
    end
    has_been_used
  end

  def destroy
    return nil if has_advert_campaign_thats_been_used?

    super
  end
end
