# frozen_string_literal: true

class Admin::ColorsController < AdminController
  before_action :assign_color, only: %i[show edit update destroy]

  def index
    @q = Color.ransack(params[:q])
    @colors = @q.result.order('name').page(params[:page]).per(20)
  end

  # GET /colors/new
  def new
    @color = Color.new
  end

  # GET /colors/1/edit
  def edit; end

  def show; end

  # POST /colors
  def create
    @color = Color.new(color_params)
    if @color.save
      redirect_to([:admin, @color], notice: 'Color was successfully created.')
    else
      flash[:alert] = 'Color was NOT created'
      render 'new'
    end
  end

  # PUT /colors/1
  def update
    if @color.update(color_params)
      redirect_to([:admin, @color], notice: 'Color was successfully updated.')
    else
      flash[:alert] = 'Color was NOT updated'
      render 'edit'
    end
  end

  # DELETE /colors/1
  def destroy
    @color.destroy
    if @color.errors.present?
      flash[:alert] = @color.errors[:base]&.join(', ')
    else
      flash[:notice] = "#{@color.name} deleted"
    end

    redirect_to(admin_colors_url)
  end

  private

  def assign_color
    @color = Color.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def color_params
    params.require(:color).permit(:name, :ldraw_id, :bl_name, :bl_id, :lego_name, :lego_id, :ldraw_rgb, :rgb)
  end
end
