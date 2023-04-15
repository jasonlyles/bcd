# frozen_string_literal: true

class Admin::ImagesController < AdminController
  before_action :assign_products
  before_action :assign_image, only: %i[show edit update destroy reposition]

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
               Image.new(product_id: params[:product_id])
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
      redirect_target = if params['image']['from_modal'] == 'true'
                          [:admin, Product.find(params['image']['product_id'])]
                        else
                          [:admin, @image]
                        end
      redirect_to(redirect_target, notice: 'Image was successfully created.')
    else
      flash[:alert] = 'Image was NOT created'
      render 'new'
    end
  end

  # PUT /images/1
  def update
    if @image.update(image_params)
      redirect_to([:admin, @image], notice: 'Image was successfully updated.')
    else
      flash[:alert] = 'Image was NOT updated'
      render 'edit'
    end
  end

  # DELETE /images/1
  def destroy
    flash[:notice] = 'Image deleted'
    @image.destroy
    redirect_back(fallback_location: '/admin/products')
  end

  # PATCH /images/1/reposition
  def reposition
    @image.insert_at(params[:position].to_i)
    head :ok
  end

  private

  def assign_products
    @products = Product.all.order('name').pluck(:name, :id)
  end

  def assign_image
    @image = Image.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def image_params
    params.require(:image).permit(:category_id, :location, :product_id, :url, :url_cache, :remove_url, :from_modal)
  end
end
