# frozen_string_literal: true

class Admin::ProductsController < AdminController
  before_action :assign_type, only: %i[new edit create update]
  before_action :find_product, only: %i[show edit update destroy]

  # GET /products
  def index
    @q = Product.ransack(params[:q])
    @products = @q.result.includes(:product_type).order('product_code').page(params[:page]).per(20)
  end

  # GET /products/1
  def show; end

  # GET /products/new
  def new
    @product = Product.new
    return unless params[:product_code]

    # This is for creating a derivative product, i.e., a model/kit based of the base product, the instructions
    product = Product.find_by_product_code(params[:product_code])
    return unless product

    @derivative_product = true
    @product = product.dup
  end

  # GET /products/1/edit
  def edit; end

  # POST /products
  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to([:admin, @product], notice: 'Product was successfully created.')
    else
      flash[:alert] = 'Product was NOT created'
      render 'new'
    end
  end

  # PUT /products/1
  def update
    if @product.update(product_params)
      BackendNotification.create(message: "#{current_radmin.email} updated the PDF for #{@product.code_and_name}. Be sure to email an update to users if necessary.") if @product.pdf_changed? && !params[:product][:remove_pdf].present?
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
    redirect_back(fallback_location: '/admin/products')
  end

  private

  def find_product
    @product = Product.find(params[:id])
  end

  def assign_type
    @product_types = ProductType.all.collect { |product_type| [product_type.name, product_type.id] }
  end

  # Only allow a trusted parameter "white list" through.
  def product_params
    # Be sure to add nested attributes at the end of the list.
    params.require(:product).permit(:category_id, :description, :discount_percentage, :name, :pdf, :pdf_cache, :price, :product_code, :product_type_id, :ready_for_public, :remove_pdf, :subcategory_id, :tweet, :free, :quantity, :alternative_build, :youtube_url, :featured, :designer, :_method, images_attributes: {}, parts_lists_attributes: {})
  end
end
