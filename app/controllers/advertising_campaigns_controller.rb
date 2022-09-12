class AdvertisingCampaignsController < AdminController
  before_filter :get_partners, :only => [:new, :create, :edit, :update]

  # GET /advertising_campaigns
  def get_partners
    @partners = Partner.all.collect { |partner| [partner.name, partner.id] }
  end

  def index
    @q = AdvertisingCampaign.ransack(params[:q])
    @advertising_campaigns = @q.result.includes(:partner).page(params[:page]).per(20)
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
