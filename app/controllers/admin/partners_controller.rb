# frozen_string_literal: true

class Admin::PartnersController < AdminController
  before_action :assign_partner, only: %i[show edit update destroy]

  # GET /partners
  def index
    @q = Partner.ransack(params[:q])
    @partners = @q.result.page(params[:page]).per(20)
  end

  # GET /partners/1
  def show; end

  # GET /partners/new
  def new
    @partner = Partner.new
  end

  # GET /partners/1/edit
  def edit; end

  # POST /partners
  def create
    @partner = Partner.new(partner_params)
    if @partner.save
      redirect_to([:admin, @partner], notice: 'Partner was successfully created.')
    else
      flash[:alert] = 'Partner was NOT created'
      render 'new'
    end
  end

  # PUT /partners/1
  def update
    if @partner.update_attributes(partner_params)
      redirect_to([:admin, @partner], notice: 'Partner was successfully updated.')
    else
      flash[:alert] = 'Partner was NOT updated'
      render 'edit'
    end
  end

  # DELETE /partners/1
  def destroy
    deleted = @partner.destroy
    unless deleted
      flash[:alert] = 'Sorry. You can\'t delete a partner that has advertising campaigns that have been used.'
      return redirect_to(admin_partners_url)
    end
    redirect_to(admin_partners_url)
  end

  private

  def assign_partner
    @partner = Partner.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def partner_params
    params.require(:partner).permit(:contact, :name, :url)
  end
end
