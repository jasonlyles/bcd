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
    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html {redirect_to(@product, :notice => 'Product was successfully updated.')}
        format.json {render json: true}
      else
        format.html {render 'edit', alert: "Product was NOT updated"}
        format.json {render json: false}
      end
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
