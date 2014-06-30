class EmailCampaignsController < ApplicationController
  before_filter :authenticate_radmin!
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc{ |controller| controller.request.xhr? ? false : "admin" }

  # GET /email_campaigns
  def index
    @email_campaigns = EmailCampaign.all
  end

  # GET /email_campaigns/1
  def show
    @email_campaign = EmailCampaign.find(params[:id])
  end

  # GET /email_campaigns/new
  def new
    @email_campaign = EmailCampaign.new
  end

  # GET /email_campaigns/1/edit
  def edit
    @email_campaign = EmailCampaign.find(params[:id])
  end

  # POST /email_campaigns
  def create
    @email_campaign = EmailCampaign.new(params[:email_campaign])
    if @email_campaign.save
      redirect_to(@email_campaign, :notice => 'Email campaign was successfully created.')
    else
      flash[:alert] = "Email Campaign was NOT created"
      render "new"
    end
  end

  # PUT /email_campaigns/1
  def update
    @email_campaign = EmailCampaign.find(params[:id])
    if @email_campaign.update_attributes(params[:email_campaign])
      redirect_to(@email_campaign, :notice => 'Email campaign was successfully updated.')
    else
      flash[:alert] = "Email campaign was NOT updated"
      render "edit"
    end
  end

  # DELETE /email_campaigns/1
  def destroy
    @email_campaign = EmailCampaign.find(params[:id])
    @email_campaign.destroy
    redirect_to(email_campaigns_url)
  end
end
