class PartnersController < ApplicationController
  before_filter :authenticate_radmin!
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc { |controller| controller.request.xhr? ? false : "admin" }

  # GET /partners
  def index
    @partners = Partner.all
  end

  # GET /partners/1
  def show
    @partner = Partner.find(params[:id])
  end

  # GET /partners/new
  def new
    @partner = Partner.new
  end

  # GET /partners/1/edit
  def edit
    @partner = Partner.find(params[:id])
  end

  # POST /partners
  def create
    @partner = Partner.new(params[:partner])
    if @partner.save
      redirect_to(@partner, :notice => 'Partner was successfully created.')
    else
      flash[:alert] = "Partner was NOT created"
      render "new"
    end
  end

  # PUT /partners/1
  def update
    @partner = Partner.find(params[:id])
    if @partner.update_attributes(params[:partner])
      redirect_to(@partner, :notice => 'Partner was successfully updated.')
    else
      flash[:alert] = "Partner was NOT updated"
      render "edit"
    end
  end

  # DELETE /partners/1
  def destroy
    @partner = Partner.find(params[:id])
    deleted = @partner.destroy
    unless deleted
      flash[:alert] = "Sorry. You can't delete a partner that has advertising campaigns that have been used."
      return redirect_to(partners_url)
    end
    redirect_to(partners_url)
  end
end
