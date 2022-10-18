class Admin::ImagesController < AdminController
  before_filter :get_products
  before_filter :get_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  def index
    @q = Image.ransack(params[:q])
    @images = @q.result.order("product_id").page(params[:page]).per(20)
  end

  # GET /images/1
  def show
  end

  # GET /images/new
  def new
    if params[:product_id]
      @image = Image.new(:product_id => params[:product_id])
    else
      @image = Image.new
    end
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  def create
    @image = Image.new(params[:image])
    if @image.save
      redirect_to([:admin, @image], notice: 'Image was successfully created.')
    else
      flash[:alert] = "Image was NOT created"
      render "new"
    end
  end

  # PUT /images/1
  def update
    if @image.update_attributes(params[:image])
      redirect_to([:admin, @image], notice: 'Image was successfully updated.')
    else
      flash[:alert] = "Image was NOT updated"
      render "edit"
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy
    redirect_to(admin_images_url)
  end

  private

  def get_products
    products = Product.all.order("name")
    @products = []
    products.each { |product| @products << [product.name, product.id] }
  end

  def get_image
    @image = Image.find(params[:id])
  end
end