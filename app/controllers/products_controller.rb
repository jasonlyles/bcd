class ProductsController < ApplicationController
  before_filter :authenticate_radmin!
  before_filter :get_categories_for_admin
  before_filter :get_type, :only => [:new, :edit, :create, :update]
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc{ |c| c.request.xhr? ? false : "admin" }

  # GET /products
  # GET /products.xml
  def index
    @products = Product.order("product_code").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        format.html { redirect_to(@product, :notice => 'Product was successfully created.') }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        flash[:alert] = "Product was NOT created"
        format.html { render "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.find(params[:id])
    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to(@product, :notice => 'Product was successfully updated.') }
        format.xml  { head :ok }
      else
        flash[:alert] = "Product was NOT updated"
        format.html { render "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end

  def retire_product
    @product = Product.find(params[:product][:id])
    @product.category_id = Category.find_by_name("Retired").id
    @product.subcategory_id = Subcategory.find_by_name("Retired").id
    @product.ready_for_public = false
    @product.save
    redirect_to :back
  end

  private

  def get_type
    @product_types = ProductType.all.collect{|x| [x.name,x.id]}
  end
end
