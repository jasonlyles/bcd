class Admin::SubcategoriesController < AdminController
  before_filter :get_categories_for_admin
  before_filter :get_subcategory, only: [:show, :edit, :update, :destroy]

  # GET /subcategories
  def index
    @q = Subcategory.ransack(params[:q])
    @subcategories = @q.result.includes(:category).page(params[:page]).per(20)
  end

  # GET /subcategories/1
  def show
  end

  # GET /subcategories/new
  def new
    @subcategory = Subcategory.new
  end

  # GET /subcategories/1/edit
  def edit
  end

  # POST /subcategories
  def create
    @subcategory = Subcategory.new(params[:subcategory])
    if @subcategory.save
      redirect_to([:admin, @subcategory], notice: 'Subcategory was successfully created.')
    else
      flash[:alert] = "Subcategory was NOT created"
      render "new"
    end
  end

  # PUT /subcategories/1
  def update
    if @subcategory.update_attributes(params[:subcategory])
      redirect_to([:admin, @subcategory], notice: 'Subcategory was successfully updated.')
    else
      flash[:alert] = "Subcategory was NOT updated."
      render "edit"
    end
  end

  # DELETE /subcategories/1
  def destroy
    if @subcategory.products.empty?
      @subcategory.destroy
    else
      return redirect_to admin_subcategories_url, alert: "You can't delete this subcategory while it has products. Delete or reassign the products and try again."
    end
    redirect_to(admin_subcategories_url)
  end

  def model_code
    @model_code = Subcategory.model_code(params[:id])
    respond_to do |format|
      format.json  { render :json => @model_code.to_json }
    end
  end

  private

  def get_subcategory
    @subcategory = Subcategory.find(params[:id])
  end
end
