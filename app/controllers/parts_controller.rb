class PartsController < AdminController
  def index
    search = if params[:term].present?
               # If search term is a number, look for ldraw or bl or lego id or alternate_nos
               # If it's letters/a word, use the name_cont
               # First, check for an integer
               if params[:term].to_i.to_s == params[:term]
                 {
                  "ldraw_id_or_bl_id_or_lego_id_or_alternate_nos_cont" => params[:term]
                 }
               else
                 {
                  "name_cont" => params[:term]
                 }
               end
             else
               params[:q]
             end
    @q = Part.ransack(search)
    @parts = @q.result.order("name").page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.json { render json: @parts.map { |p| p['name'] } }
    end
  end

  # GET /parts/new
  def new
    @part = Part.new
  end

  # GET /parts/1/edit
  def edit
    @part = Part.find(params[:id])
  end

  def show
    @part = Part.find(params[:id])
  end

  # POST /parts
  def create
    @part = Part.new(params[:part])
    if @part.save
      redirect_to(@part, notice: 'Part was successfully created.')
    else
      flash[:alert] = "Part was NOT created"
      render "new"
    end
  end

  # PUT /parts/1
  def update
    @part = Part.find(params[:id])
    if @part.update_attributes(params[:part])
      redirect_to(@part, :notice => 'Part was successfully updated.')
    else
      flash[:alert] = "Part was NOT updated"
      render "edit"
    end
  end

  # DELETE /parts/1
  def destroy
    @part = Part.find(params[:id])
    @part.destroy
    redirect_to(parts_url)
  end
end
