class UpdatesController < ApplicationController
  before_filter :authenticate_radmin!
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc { |controller| controller.request.xhr? ? false : "admin" }

  # GET /updates
  def index
    @updates = Update.order('created_at desc').page(params[:page]).per(10)
  end

  # GET /updates/1
  def show
    @update = Update.find(params[:id])
  end

  # GET /updates/new
  def new
    @update = Update.new
  end

  # GET /updates/1/edit
  def edit
    @update = Update.find(params[:id])
  end

  # POST /updates
  def create
    @update = Update.new(params[:update])
    if @update.save
      redirect_to(@update, :notice => 'Update was successfully created.')
    else
      flash[:alert] = "Update was NOT created."
      render "new"
    end
  end

  # PUT /updates/1
  def update
    @update = Update.find(params[:id])
    if @update.update_attributes(params[:update])
      redirect_to(@update, :notice => 'Update was successfully updated.')
    else
      flash[:alert] = "Update was NOT updated."
      render "edit"
    end
  end

  # DELETE /updates/1
  def destroy
    @update = Update.find(params[:id])
    @update.destroy
    redirect_to(updates_url)
  end
end
