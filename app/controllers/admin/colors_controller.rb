class Admin::ColorsController < AdminController
  before_filter :get_color, only: [:show, :edit, :update, :destroy]

  def index
    @q = Color.ransack(params[:q])
    @colors = @q.result.order("name").page(params[:page]).per(20)
  end

  # GET /colors/new
  def new
    @color = Color.new
  end

  # GET /colors/1/edit
  def edit
  end

  def show
  end

  # POST /colors
  def create
    @color = Color.new(params[:color])
    if @color.save
      redirect_to([:admin, @color], notice: 'Color was successfully created.')
    else
      flash[:alert] = "Color was NOT created"
      render "new"
    end
  end

  # PUT /colors/1
  def update
    if @color.update_attributes(params[:color])
      redirect_to([:admin, @color], notice: 'Color was successfully updated.')
    else
      flash[:alert] = "Color was NOT updated"
      render "edit"
    end
  end

  # DELETE /colors/1
  def destroy
    @color.destroy
    redirect_to(admin_colors_url)
  end

  private

  def get_color
    @color = Color.find(params[:id])
  end
end
