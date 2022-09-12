class CategoriesController < AdminController

  # GET /categories
  def index
    @categories = Category.all
  end

  def subcategories
    @category = Category.find(params[:id])
    respond_to do |format|
      format.json  { render :json => @category.subcategories }
    end
  end

  # GET /categories/1
  def show
    @category = Category.find(params[:id])
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
  end

  # POST /categories
  def create
    @category = Category.new(params[:category])
    if @category.save
      redirect_to(@category, :notice => 'Category was successfully created.')
    else
      flash[:alert] = "Category was NOT created"
      render "new"
    end
  end

  # PUT /categories/1
  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      redirect_to(@category, :notice => 'Category was successfully updated.')
    else
      flash[:alert] = "Category was NOT updated"
      render "edit"
    end
  end

  # DELETE /categories/1
  def destroy
    @category = Category.find(params[:id])
    if @category.subcategories.empty?
      @category.destroy
    else
      return redirect_to categories_url, :alert => "You can't delete this category while it has subcategories. Delete or reassign the subcategories and try again."
    end
    redirect_to(categories_url)
  end
end
