# frozen_string_literal: true

class Admin::CategoriesController < AdminController
  before_action :assign_category, only: %i[show edit update destroy]

  # GET /categories
  def index
    @q = Category.ransack(params[:q])
    @categories = @q.result.page(params[:page]).per(20)
  end

  def subcategories
    @category = Category.find(params[:id])
    respond_to do |format|
      format.json { render json: @category.subcategories }
    end
  end

  # GET /categories/1
  def show; end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit; end

  # POST /categories
  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to([:admin, @category], notice: 'Category was successfully created.')
    else
      flash[:alert] = 'Category was NOT created'
      render 'new'
    end
  end

  # PUT /categories/1
  def update
    if @category.update(category_params)
      redirect_to([:admin, @category], notice: 'Category was successfully updated.')
    else
      flash[:alert] = 'Category was NOT updated'
      render 'edit'
    end
  end

  # DELETE /categories/1
  def destroy
    return redirect_to admin_categories_url, alert: 'You can\'t delete this category while it has subcategories. Delete or reassign the subcategories and try again.' unless @category.subcategories.empty?

    @category.destroy
    redirect_to(admin_categories_url)
  end

  private

  def assign_category
    @category = Category.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def category_params
    params.require(:category).permit(:name, :description, :ready_for_public, :image, :image_cache, :remove_image)
  end
end
