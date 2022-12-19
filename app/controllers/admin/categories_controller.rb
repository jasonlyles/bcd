class Admin::CategoriesController < AdminController
  before_filter :get_category, only: [:show, :edit, :update, :destroy]

  # GET /categories
  def index
    @q = Category.ransack(params[:q])
    @categories = @q.result.page(params[:page]).per(20)
  end

  def subcategories
    @category = Category.find(params[:id])
    respond_to do |format|
      format.json  { render json: @category.subcategories }
    end
  end

  # GET /categories/1
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  def create
    @category = Category.new(params[:category])
    if @category.save
      redirect_to([:admin, @category], notice: 'Category was successfully created.')
    else
      flash[:alert] = "Category was NOT created"
      render "new"
    end
  end

  # PUT /categories/1
  def update
    if @category.update_attributes(params[:category])
      redirect_to([:admin, @category], notice: 'Category was successfully updated.')
    else
      flash[:alert] = "Category was NOT updated"
      render "edit"
    end
  end

  # DELETE /categories/1
  def destroy
    if @category.subcategories.empty?
      @category.destroy
    else
      return redirect_to admin_categories_url, alert: "You can't delete this category while it has subcategories. Delete or reassign the subcategories and try again."
    end
    redirect_to(admin_categories_url)
  end

  private

  def get_category
    @category = Category.find(params[:id])
  end
end
