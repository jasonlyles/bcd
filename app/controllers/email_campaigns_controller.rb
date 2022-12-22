# frozen_string_literal: true

class EmailCampaignsController < ApplicationController
  def register_click_through_and_redirect
    @email_campaign = EmailCampaign.where(['guid = ?', params[:guid]])
    if @email_campaign
      @email_campaign.click_throughs += 1
      @email_campaign.save
      redirect_to @email_campaign.redirect_link
    else
      redirect_to '/'
    end
  end
end
