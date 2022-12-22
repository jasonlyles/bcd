# frozen_string_literal: true

class Admin::EmailCampaignsController < AdminController
  before_action :assign_email_campaign, only: %i[show edit update destroy]

  # GET /email_campaigns
  def index
    @q = EmailCampaign.ransack(params[:q])
    @email_campaigns = @q.result.page(params[:page]).per(20)
  end

  # GET /email_campaigns/1
  def show; end

  # GET /email_campaigns/new
  def new
    @email_campaign = EmailCampaign.new
  end

  # GET /email_campaigns/1/edit
  def edit; end

  # POST /email_campaigns
  def create
    @email_campaign = EmailCampaign.new(email_campaign_params)
    if @email_campaign.save
      redirect_to([:admin, @email_campaign], notice: 'Email campaign was successfully created.')
    else
      flash[:alert] = 'Email Campaign was NOT created'
      render 'new'
    end
  end

  # PUT /email_campaigns/1
  def update
    if @email_campaign.update_attributes(email_campaign_params)
      redirect_to([:admin, @email_campaign], notice: 'Email campaign was successfully updated.')
    else
      flash[:alert] = 'Email campaign was NOT updated'
      render 'edit'
    end
  end

  # DELETE /email_campaigns/1
  def destroy
    flash[:alert] = if @email_campaign.destroy
                      'Email Campaign destroyed'
                    else
                      'Did not destroy this marketing campaign due to emails having been sent for it. Destroying it now would lose valuable reporting data.'
                    end

    redirect_to(admin_email_campaigns_url)
  end

  def send_marketing_emails
    @email_campaign = EmailCampaign.find(params[:email_campaign][:id])
    if @email_campaign.emails_sent.positive?
      flash[:alert] = 'This email campaign has already been activated'
      redirect_to admin_email_campaigns_path(@email_campaign)
      return
    end

    NewMarketingNotificationJob.perform_later(email_campaign: @email_campaign.id)
    flash[:notice] = 'Sending marketing emails'
    redirect_to admin_email_campaigns_path
  end

  def send_marketing_email_preview
    @email_campaign = EmailCampaign.find(params[:email_campaign][:id])
    NewMarketingNotificationJob.perform_later(email_campaign: @email_campaign.id, preview_only: true)
    flash[:notice] = 'Sending marketing email preview'
    redirect_to admin_email_campaign_path(@email_campaign)
  end

  private

  def assign_email_campaign
    @email_campaign = EmailCampaign.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def email_campaign_params
    params.require(:email_campaign).permit(:click_throughs, :description, :image, :image_cache, :remove_image, :message, :subject, :emails_sent, :guid, :redirect_link)
  end
end
