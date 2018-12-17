class EmailCampaignsController < ApplicationController
  before_filter :authenticate_radmin!, except: ['register_click_through_and_redirect']
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc { |controller| controller.request.xhr? ? false : 'admin' }

  def send_marketing_emails
    @email_campaign = EmailCampaign.find(params[:email_campaign][:id])
    queued = NewMarketingNotificationJob.create(email_campaign: @email_campaign.id)
    if queued.nil?
      flash[:alert] = "Couldn't queue email jobs. Check out /jobs and see what's wrong"
      redirect_to controller: :email_campaigns, action: :show, id: @email_campaign.id
    else
      flash[:notice] = 'Sending marketing emails'
      redirect_to controller: :email_campaigns, action: :index
    end
  end

  def send_marketing_email_preview
    @email_campaign = EmailCampaign.find(params[:email_campaign][:id])
    queued = NewMarketingNotificationJob.create(email_campaign: @email_campaign.id, preview_only: true)
    if queued.nil?
      flash[:alert] = "Couldn't queue email jobs. Check out /jobs and see what's wrong"
      redirect_to @email_campaign
    else
      flash[:notice] = 'Sending marketing email preview'
      redirect_to @email_campaign
    end
  end

  def register_click_through_and_redirect
    @email_campaign = EmailCampaign.find_by_guid(params[:guid])
    if @email_campaign
      @email_campaign.click_throughs += 1
      @email_campaign.save
      redirect_to @email_campaign.redirect_link
    else
      redirect_to '/'
    end
  end
end
