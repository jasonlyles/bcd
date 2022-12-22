# frozen_string_literal: true

class Admin::ImagesController < AdminController
  before_action :assign_products
  before_action :assign_image, only: %i[show edit update destroy]

  # GET /images
  def index
    @q = Image.ransack(params[:q])
    @images = @q.result.order('product_id').page(params[:page]).per(20)
  end

  # GET /images/1
  def show; end

  # GET /images/new
  def new
    @image = if params[:product_id]
               Image.new(:product_id => params[:product_id])
             else
               Image.new
             end
  end

  # GET /images/1/edit
  def edit; end

  # POST /images
  def create
    @image = Image.new(image_params)
    if @image.save
      redirect_to([:admin, @image], notice: 'Image was successfully created.')
    else
      flash[:alert] = 'Image was NOT created'
      render 'new'
    end
  end

  # PUT /images/1
  def update
    if @image.update_attributes(image_params)
      redirect_to([:admin, @image], notice: 'Image was successfully updated.')
    else
      flash[:alert] = 'Image was NOT updated'
      render 'edit'
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy
    redirect_to(admin_images_url)
  end

  private

  def assign_products
    products = Product.all.order('name')
    @products = []
    products.each { |product| @products << [product.name, product.id] }
  end

  def assign_image
    @image = Image.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def image_params
    params.require(:image).permit(:category_id, :location, :product_id, :url, :url_cache, :remove_url)
  end
end
