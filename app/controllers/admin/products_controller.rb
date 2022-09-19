class Admin::ProductsController < AdminController
  before_filter :get_type, :only => [:new, :edit, :create, :update]
  before_filter :find_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  def index
    @q = Product.ransack(params[:q])
    @products = @q.result.includes(:product_type).order('product_code').page(params[:page]).per(20)
  end

  # GET /products/1
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    if params[:product_code]
      #This is for creating a derivative product, i.e., a model/kit based of the base product, the instructions
      product = Product.find_by_product_code(params[:product_code])
      if product
        @derivative_product = true
        @product = product.dup
      end
    end
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  def create
    @product = Product.new(params[:product])
    if @product.save
      redirect_to([:admin, @product], notice: 'Product was successfully created.')
    else
      flash[:alert] = "Product was NOT created"
      render 'new'
    end
  end

  # PUT /products/1
  def update
    if @product.update_attributes(params[:product])
      redirect_to([:admin, @product], notice: 'Product was successfully updated.')
    else
      flash[:alert] = 'Product was NOT updated'
      render 'edit'
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
    redirect_to(admin_products_url)
  end

  def retire_product
    @product = Product.find(params[:product][:id])
    @product.retire
    redirect_to :back
  end

  private

  def find_product
    @product = Product.find(params[:id])
  end

  def get_type
    @product_types = ProductType.all.collect{|product_type| [product_type.name,product_type.id]}
  end
end
