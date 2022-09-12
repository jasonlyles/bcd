class ColorsController < AdminController

  def index
    @q = Color.ransack(params[:q])
    @colors = @q.result.order("name").page(params[:page]).per(20)
  end

  # GET /colors/new
  def new
    @color = Color.new
  end

  # GET /colors/1/edit
  def edit
    @color = Color.find(params[:id])
  end

  def show
    @color = Color.find(params[:id])
  end

  # POST /colors
  def create
    @color = Color.new(params[:color])
    if @color.save
      redirect_to(@color, notice: 'Color was successfully created.')
    else
      flash[:alert] = "Color was NOT created"
      render "new"
    end
  end

  # PUT /colors/1
  def update
    @color = Color.find(params[:id])
    if @color.update_attributes(params[:color])
      redirect_to(@color, :notice => 'Color was successfully updated.')
    else
      flash[:alert] = "Color was NOT updated"
      render "edit"
    end
  end

  # DELETE /colors/1
  def destroy
    @color = Color.find(params[:id])
    @color.destroy
    redirect_to(colors_url)
  end
end
