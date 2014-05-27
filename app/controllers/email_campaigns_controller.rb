class EmailCampaignsController < ApplicationController
  before_filter :authenticate_radmin!
  layout proc{ |c| c.request.xhr? ? false : "admin" }
  # GET /email_campaigns
  # GET /email_campaigns.xml
  def index
    @email_campaigns = EmailCampaign.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @email_campaigns }
    end
  end

  # GET /email_campaigns/1
  # GET /email_campaigns/1.xml
  def show
    @email_campaign = EmailCampaign.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email_campaign }
    end
  end

  # GET /email_campaigns/new
  # GET /email_campaigns/new.xml
  def new
    @email_campaign = EmailCampaign.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email_campaign }
    end
  end

  # GET /email_campaigns/1/edit
  def edit
    @email_campaign = EmailCampaign.find(params[:id])
  end

  # POST /email_campaigns
  # POST /email_campaigns.xml
  def create
    @email_campaign = EmailCampaign.new(params[:email_campaign])

    respond_to do |format|
      if @email_campaign.save
        format.html { redirect_to(@email_campaign, :notice => 'Email campaign was successfully created.') }
        format.xml  { render :xml => @email_campaign, :status => :created, :location => @email_campaign }
      else
        flash[:alert] = "Email Campaign was NOT created"
        format.html { render :action => "new" }
        format.xml  { render :xml => @email_campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /email_campaigns/1
  # PUT /email_campaigns/1.xml
  def update
    @email_campaign = EmailCampaign.find(params[:id])

    respond_to do |format|
      if @email_campaign.update_attributes(params[:email_campaign])
        format.html { redirect_to(@email_campaign, :notice => 'Email campaign was successfully updated.') }
        format.xml  { head :ok }
      else
        flash[:alert] = "Email campaign was NOT updated"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email_campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /email_campaigns/1
  # DELETE /email_campaigns/1.xml
  def destroy
    @email_campaign = EmailCampaign.find(params[:id])
    @email_campaign.destroy

    respond_to do |format|
      format.html { redirect_to(email_campaigns_url) }
      format.xml  { head :ok }
    end
  end
end
