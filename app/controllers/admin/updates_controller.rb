class Admin::UpdatesController < AdminController
  before_filter :get_update, only: [:show, :edit, :update, :destroy]

  # GET /updates
  def index
    @q = Update.ransack(params[:q])
    @updates = @q.result.order('created_at desc').page(params[:page]).per(10)
  end

  # GET /updates/1
  def show
  end

  # GET /updates/new
  def new
    @update = Update.new
  end

  # GET /updates/1/edit
  def edit
  end

  # POST /updates
  def create
    @update = Update.new(params[:update])
    if @update.save
      redirect_to([:admin, @update], notice: 'Update was successfully created.')
    else
      flash[:alert] = "Update was NOT created."
      render "new"
    end
  end

  # PUT /updates/1
  def update
    if @update.update_attributes(params[:update])
      redirect_to([:admin, @update], notice: 'Update was successfully updated.')
    else
      flash[:alert] = "Update was NOT updated."
      render "edit"
    end
  end

  # DELETE /updates/1
  def destroy
    @update.destroy
    redirect_to(admin_updates_url)
  end

  private

  def get_update
    @update = Update.find(params[:id])
  end
end
