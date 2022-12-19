class Admin::PartnersController < AdminController
  before_filter :get_partner, only: [:show, :edit, :update, :destroy]

  # GET /partners
  def index
    @q = Partner.ransack(params[:q])
    @partners = @q.result.page(params[:page]).per(20)
  end

  # GET /partners/1
  def show
  end

  # GET /partners/new
  def new
    @partner = Partner.new
  end

  # GET /partners/1/edit
  def edit
  end

  # POST /partners
  def create
    @partner = Partner.new(params[:partner])
    if @partner.save
      redirect_to([:admin, @partner], notice: 'Partner was successfully created.')
    else
      flash[:alert] = "Partner was NOT created"
      render "new"
    end
  end

  # PUT /partners/1
  def update
    if @partner.update_attributes(params[:partner])
      redirect_to([:admin, @partner], notice: 'Partner was successfully updated.')
    else
      flash[:alert] = "Partner was NOT updated"
      render "edit"
    end
  end

  # DELETE /partners/1
  def destroy
    deleted = @partner.destroy
    unless deleted
      flash[:alert] = "Sorry. You can't delete a partner that has advertising campaigns that have been used."
      return redirect_to(admin_partners_url)
    end
    redirect_to(admin_partners_url)
  end

  private

  def get_partner
    @partner = Partner.find(params[:id])
  end
end
