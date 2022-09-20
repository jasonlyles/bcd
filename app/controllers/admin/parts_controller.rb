class Admin::PartsController < AdminController
  before_filter :get_part, only: [:show, :edit, :update, :destroy, :update_via_bricklink, :update_via_rebrickable]

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
  end

  def show
  end

  # POST /parts
  def create
    @part = Part.new(params[:part])
    if @part.save
      PartInteractions::UpdateFromBricklink.run(part: @part) if @part.check_bricklink?
      PartInteractions::UpdateFromRebrickable.run(part: @part) if @part.check_rebrickable?
      redirect_to([:admin, @part], notice: 'Part was successfully created.')
    else
      flash[:alert] = "Part was NOT created"
      render "new"
    end
  end

  # PUT /parts/1
  def update
    if @part.update_attributes(params[:part])
      PartInteractions::UpdateFromBricklink.run(part: @part) if @part.check_bricklink?
      PartInteractions::UpdateFromRebrickable.run(part: @part) if @part.check_rebrickable?
      redirect_to([:admin, @part], notice: 'Part was successfully updated.')
    else
      flash[:alert] = "Part was NOT updated"
      render "edit"
    end
  end

  # DELETE /parts/1
  def destroy
    @part.destroy
    if @part.errors.present?
      flash[:alert] = @part.errors[:base]&.join(', ')
    else
      flash[:notice] = "#{@part.name} deleted"
    end

    redirect_to(admin_parts_url)
  end

  def update_via_bricklink
    interaction = PartInteractions::UpdateFromBricklink.run(part: @part)
    if interaction.succeeded?
      flash[:notice] = 'Successfully updated part via BrickLink'
    else
      flash[:alert] = interaction.error
    end

    redirect_to :back
  end

  def update_via_rebrickable
    interaction = PartInteractions::UpdateFromRebrickable.run(part: @part)
    if interaction.succeeded?
      flash[:notice] = 'Successfully updated part via Rebrickable'
    else
      flash[:alert] = interaction.error
    end

    redirect_to :back
  end

  private

  def get_part
    @part = Part.find(params[:id])
  end
end
