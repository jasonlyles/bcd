class SubcategoriesController < AdminController
  before_filter :get_categories_for_admin

  # GET /subcategories
  def index
    @subcategories = Subcategory.all
  end

  # GET /subcategories/1
  def show
    @subcategory = Subcategory.find(params[:id])
  end

  # GET /subcategories/new
  def new
    @subcategory = Subcategory.new
  end

  # GET /subcategories/1/edit
  def edit
    @subcategory = Subcategory.find(params[:id])
  end

  # POST /subcategories
  def create
    @subcategory = Subcategory.new(params[:subcategory])
    if @subcategory.save
      redirect_to(@subcategory, :notice => 'Subcategory was successfully created.')
    else
      flash[:alert] = "Subcategory was NOT created"
      render "new"
    end
  end

  # PUT /subcategories/1
  def update
    @subcategory = Subcategory.find(params[:id])
    if @subcategory.update_attributes(params[:subcategory])
      redirect_to(@subcategory, :notice => 'Subcategory was successfully updated.')
    else
      flash[:alert] = "Subcategory was NOT updated."
      render "edit"
    end
  end

  # DELETE /subcategories/1
  def destroy
    @subcategory = Subcategory.find(params[:id])
    if @subcategory.products.empty?
      @subcategory.destroy
    else
      return redirect_to subcategories_url, :alert => "You can't delete this subcategory while it has products. Delete or reassign the products and try again."
    end
    redirect_to(subcategories_url)
  end

  def model_code
    @model_code = Subcategory.model_code(params[:id])
    respond_to do |format|
      format.json  { render :json => @model_code.to_json }
    end
  end
end
