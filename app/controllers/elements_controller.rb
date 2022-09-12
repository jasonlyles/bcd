class ElementsController < AdminController

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
    @element = Element.find(params[:id])
  end

  def show
    @element = Element.find(params[:id])
  end

  # POST /elements
  def create
    @element = Element.new(params[:element])
    if @element.save
      redirect_to(@element, notice: 'Element was successfully created.')
    else
      flash[:alert] = "Element was NOT created"
      render "new"
    end
  end

  # PUT /elements/1
  def update
    @element = Element.find(params[:id])
    if @element.update_attributes(params[:element])
      if params['element']['remove_image'].present? && params['element']['remove_image'] == '1'
        flash[:notice] = 'Element was successfully updated.'
        render "edit"
      else
        redirect_to(@element, notice: 'Element was successfully updated.')
      end
    else
      flash[:alert] = "Element was NOT updated"
      render "edit"
    end
  end

  # DELETE /elements/1
  def destroy
    @element = Element.find(params[:id])
    @element.destroy
    redirect_to(elements_url)
  end

  def find_or_create
    part_id = Part.find_by(name: params[:part_name]).ldraw_id
    color_id = Color.find(params[:color_id]).ldraw_id

    element_key = "#{part_id}_#{color_id}"
    element = Element.find_or_create_via_external(element_key)

    render json: element.as_json.merge(part_ldraw_id: part_id, part_ldraw_color_id: color_id)
  end
end
