class AdvertisingCampaignsController < ApplicationController
  before_filter :authenticate_radmin!
  before_filter :get_partners, :only => [:new, :create, :edit, :update]
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc { |c| c.request.xhr? ? false : "admin" }

  # GET /advertising_campaigns
  # GET /advertising_campaigns.xml
  def get_partners
    @partners = Partner.all.collect { |x| [x.name, x.id] }
  end

  def index
    @advertising_campaigns = AdvertisingCampaign.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @advertising_campaigns }
    end
  end

  # GET /advertising_campaigns/1
  # GET /advertising_campaigns/1.xml
  def show
    @advertising_campaign = AdvertisingCampaign.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @advertising_campaign }
    end
  end

  # GET /advertising_campaigns/new
  # GET /advertising_campaigns/new.xml
  def new
    @advertising_campaign = AdvertisingCampaign.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @advertising_campaign }
    end
  end

  # GET /advertising_campaigns/1/edit
  def edit
    @advertising_campaign = AdvertisingCampaign.find(params[:id])
  end

  # POST /advertising_campaigns
  # POST /advertising_campaigns.xml
  def create
    @advertising_campaign = AdvertisingCampaign.new(params[:advertising_campaign])

    respond_to do |format|
      if @advertising_campaign.save
        format.html { redirect_to(@advertising_campaign, :notice => 'Advertising campaign was successfully created.') }
        format.xml  { render :xml => @advertising_campaign, :status => :created, :location => @advertising_campaign }
      else
        flash[:alert] = "Advertising Campaign was NOT created"
        format.html { render "new" }
        format.xml  { render :xml => @advertising_campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /advertising_campaigns/1
  # PUT /advertising_campaigns/1.xml
  def update
    @advertising_campaign = AdvertisingCampaign.find(params[:id])

    respond_to do |format|
      if @advertising_campaign.update_attributes(params[:advertising_campaign])
        format.html { redirect_to(@advertising_campaign, :notice => 'Advertising campaign was successfully updated.') }
        format.xml  { head :ok }
      else
        flash[:alert] = "Advertising Campaign was NOT updated"
        format.html { render "edit" }
        format.xml  { render :xml => @advertising_campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /advertising_campaigns/1
  # DELETE /advertising_campaigns/1.xml
  def destroy
    @advertising_campaign = AdvertisingCampaign.find(params[:id])
    @advertising_campaign.destroy

    respond_to do |format|
      format.html { redirect_to(advertising_campaigns_url) }
      format.xml  { head :ok }
    end
  end
end
