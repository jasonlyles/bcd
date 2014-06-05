class ProductTypesController < ApplicationController
  before_action :set_product_type, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_radmin!
  skip_before_filter :find_cart
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  layout proc{ |c| c.request.xhr? ? false : "admin" }

  # GET /product_types
  def index
    @product_types = ProductType.all
  end

  # GET /product_types/1
  def show
  end

  # GET /product_types/new
  def new
    @product_type = ProductType.new
  end

  # GET /product_types/1/edit
  def edit
  end

  # POST /product_types
  def create
    @product_type = ProductType.new(product_type_params)

    if @product_type.save
      redirect_to @product_type, notice: 'Product type was successfully created.'
    else
      render 'new'
    end
  end

  # PATCH/PUT /product_types/1
  def update
    if @product_type.update(product_type_params)
      redirect_to @product_type, notice: 'Product type was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /product_types/1
  def destroy
    @product_type.destroy
    redirect_to product_types_url, notice: 'Product type was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_type
      @product_type = ProductType.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_type_params
      params.require(:product_type).permit(:name, :description, :image, :image_cache, :remove_image, :ready_for_public,
                                           :comes_with_description, :comes_with_title, :digital_product)
    end
end
