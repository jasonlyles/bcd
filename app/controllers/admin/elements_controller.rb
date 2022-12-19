class Admin::ElementsController < AdminController
  before_filter :get_element, only: [:show, :edit, :update, :destroy]

  def index
    @q = Element.includes(:part, :color).ransack(params[:q])
    @elements = @q.result.references(:part, :color).order("parts.name, colors.name").page(params[:page]).per(20)
  end

  # GET /elements/new
  def new
    @element = Element.new
  end

  # GET /elements/1/edit
  def edit
  end

  def show
    @parts_list_count = @element.lots.count
  end

  # POST /elements
  def create
    @element = Element.new(params[:element])
    if @element.save
      redirect_to([:admin, @element], notice: 'Element was successfully created.')
    else
      flash[:alert] = "Element was NOT created"
      render "new"
    end
  end

  # PUT /elements/1
  def update
    if @element.update_attributes(params[:element])
      if params['element']['remove_image'].present? && params['element']['remove_image'] == '1'
        flash[:notice] = 'Element was successfully updated.'
        render "edit"
      else
        redirect_to([:admin, @element], notice: 'Element was successfully updated.')
      end
    else
      flash[:alert] = "Element was NOT updated"
      render "edit"
    end
  end

  # DELETE /elements/1
  def destroy
    @element.destroy
    if @element.errors.present?
      flash[:alert] = @element.errors[:base]&.join(', ')
    else
      flash[:notice] = "#{@element.color.bl_name} #{@element.part.name} deleted"
    end
    redirect_to(admin_elements_url)
  end

  def find_or_create
    # Strip the BL ID/ Ldraw ID in parens off the end that are used to help the
    # user decide if this is the generation of the part they want.
    part_name = params[:part_name].gsub(/\(\w+\/\w+\)$/, '').strip
    part_id = Part.find_by(name: part_name).ldraw_id
    color_id = Color.find(params[:color_id]).ldraw_id

    element_key = "#{part_id}_#{color_id}"
    element = Element.find_or_create_via_external(element_key)

    render json: element.as_json.merge(part_ldraw_id: part_id, part_ldraw_color_id: color_id)
  end

  private

  def get_element
    @element = Element.find(params[:id])
  end
end
