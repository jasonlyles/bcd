class ProductsController < ApplicationController
  before_filter :authenticate_radmin!
  before_filter :get_categories_for_admin
  before_filter :get_type, :only => [:new, :edit, :create, :update]
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc{ |controller| controller.request.xhr? ? false : "admin" }

  # GET /products
  def index
    @products = Product.order("product_code").page(params[:page]).per(20)
  end

  # GET /products/1
  def show
    @product = Product.find(params[:id])
  end

  # GET /products/new
  def new
    @product = Product.new
    #This is for creating a derivative product, i.e., a model/kit based of the base product, the instructions
    if params[:product_code]
      @derivative_product = true
      product = Product.find_by_product_code(params[:product_code])
      @product.name = product.name
      @product.product_type_id = product.product_type_id
      @product.category_id = product.category_id
      @product.subcategory_id = product.subcategory_id
      @product.price = product.price
      @product.description = product.description
      @product.product_code = product.product_code
      @product.ready_for_public = product.ready_for_public
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  def create
    @product = Product.new(params[:product])
    if @product.save
      redirect_to(@product, :notice => 'Product was successfully created.')
    else
      flash[:alert] = "Product was NOT created"
      render "new"
    end
  end

  # PUT /products/1
  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      redirect_to(@product, :notice => 'Product was successfully updated.')
    else
      flash[:alert] = "Product was NOT updated"
      render "edit"
    end
  end

  # DELETE /products/1
  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to(products_url)
  end

  def retire_product
    @product = Product.find(params[:product][:id])
    @product.retire
    redirect_to :back
  end

  private

  def get_type
    @product_types = ProductType.all.collect{|product_type| [product_type.name,product_type.id]}
  end
end
