# frozen_string_literal: true

class Admin::AdvertisingCampaignsController < AdminController
  before_action :assign_partners, only: %i[new create edit update]
  before_action :assign_advertising_campaign, only: %i[show edit update destroy]

  # GET /advertising_campaigns
  def assign_partners
    @partners = Partner.all.collect { |partner| [partner.name, partner.id] }
  end

  def index
    @q = AdvertisingCampaign.ransack(params[:q])
    @advertising_campaigns = @q.result.includes(:partner).page(params[:page]).per(20)
  end

  # GET /advertising_campaigns/1
  def show; end

  # GET /advertising_campaigns/new
  def new
    @advertising_campaign = AdvertisingCampaign.new
  end

  # GET /advertising_campaigns/1/edit
  def edit; end

  # POST /advertising_campaigns
  def create
    @advertising_campaign = AdvertisingCampaign.new(advertising_campaign_params)
    if @advertising_campaign.save
      redirect_to([:admin, @advertising_campaign], notice: 'Advertising campaign was successfully created.')
    else
      flash[:alert] = 'Advertising Campaign was NOT created'
      render 'new'
    end
  end

  # PUT /advertising_campaigns/1
  def update
    if @advertising_campaign.update(advertising_campaign_params)
      redirect_to([:admin, @advertising_campaign], notice: 'Advertising campaign was successfully updated.')
    else
      flash[:alert] = 'Advertising Campaign was NOT updated'
      render 'edit'
    end
  end

  # DELETE /advertising_campaigns/1
  def destroy
    @advertising_campaign.destroy
    redirect_to(admin_advertising_campaigns_url)
  end

  private

  def assign_advertising_campaign
    @advertising_campaign = AdvertisingCampaign.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def advertising_campaign_params
    params.require(:advertising_campaign).permit(:campaign_live, :description, :partner_id, :reference_code)
  end
end
