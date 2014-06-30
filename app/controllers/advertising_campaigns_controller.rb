class AdvertisingCampaignsController < ApplicationController
  before_filter :authenticate_radmin!
  before_filter :get_partners, :only => [:new, :create, :edit, :update]
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc { |controller| controller.request.xhr? ? false : "admin" }

  # GET /advertising_campaigns
  def get_partners
    @partners = Partner.all.collect { |partner| [partner.name, partner.id] }
  end

  def index
    @advertising_campaigns = AdvertisingCampaign.all
  end

  # GET /advertising_campaigns/1
  def show
    @advertising_campaign = AdvertisingCampaign.find(params[:id])
  end

  # GET /advertising_campaigns/new
  def new
    @advertising_campaign = AdvertisingCampaign.new
  end

  # GET /advertising_campaigns/1/edit
  def edit
    @advertising_campaign = AdvertisingCampaign.find(params[:id])
  end

  # POST /advertising_campaigns
  def create
    @advertising_campaign = AdvertisingCampaign.new(params[:advertising_campaign])
    if @advertising_campaign.save
      redirect_to(@advertising_campaign, :notice => 'Advertising campaign was successfully created.')
    else
      flash[:alert] = "Advertising Campaign was NOT created"
      render "new"
    end
  end

  # PUT /advertising_campaigns/1
  def update
    @advertising_campaign = AdvertisingCampaign.find(params[:id])
    if @advertising_campaign.update_attributes(params[:advertising_campaign])
      redirect_to(@advertising_campaign, :notice => 'Advertising campaign was successfully updated.')
    else
      flash[:alert] = "Advertising Campaign was NOT updated"
      render "edit"
    end
  end

  # DELETE /advertising_campaigns/1
  def destroy
    @advertising_campaign = AdvertisingCampaign.find(params[:id])
    @advertising_campaign.destroy
    redirect_to(advertising_campaigns_url)
  end
end
