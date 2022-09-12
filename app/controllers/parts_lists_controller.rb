class PartsListsController < AdminController
  before_filter :set_colors
  before_filter :cleanup_lots_params, only: [:create, :update]
  before_filter :cleanup_uploaded_file_params, only: [:create, :update]

  def index
    @q = PartsList.ransack(params[:q])
    @parts_lists = @q.result.includes(:product, :lots).order("name").page(params[:page]).per(20)
  end

  # GET /parts_lists/new
  def new
    @parts_list = PartsList.new
    @lots = @parts_list.lots.includes(:part, :color, element: :part).order("parts.name ASC, colors.bl_name ASC")
  end

  # GET /parts_lists/1/edit
  def edit
    @parts_list = PartsList.includes(elements: :part).find(params[:id])
    @lots = @parts_list.lots.includes(:part, :color, element: :part).order("parts.name ASC, colors.bl_name ASC")
  end

  def show
    @parts_list = PartsList.includes(elements: :part).find(params[:id])
    @lots = @parts_list.lots.includes(:part, :color, element: :part).order("parts.name ASC, colors.bl_name ASC")

    if @parts_list.bricklink_xml?
      xml_doc = Nokogiri::XML(@parts_list.bricklink_xml)
      @source_lot_count = xml_doc.xpath("//ITEM").count
      @source_total_quantity = xml_doc.xpath("//ITEM//MINQTY").collect { |c| c.text.to_i }.sum
    elsif @parts_list.ldr?
      # TODO: Get this figured out for LDRs after done with LdrParser class
      @source_lot_count = 0
      @source_total_quantity = 0
    end
  end

  # POST /parts_lists
  def create
    @parts_list = PartsList.new(params[:parts_list].except(:file))
    if @parts_list.save
      PartsListInteractions::CreatePartsList.run(parts_list_id: @parts_list.id)
      redirect_to(@parts_list, notice: 'Parts List was successfully created.')
    else
      flash[:alert] = "Parts List was NOT created"
      render "new"
    end
  end

  # PUT /parts_lists/1
  def update
    @parts_list = PartsList.find(params[:id])
    if @parts_list.update_attributes(params[:parts_list].except(:file))
      redirect_to(@parts_list, :notice => 'Parts List was successfully updated.')
    else
      flash[:alert] = "Parts List was NOT updated"
      render "edit"
    end
  end

  # DELETE /parts_lists/1
  def destroy
    @parts_list = PartsList.find(params[:id])
    @parts_list.destroy
    redirect_to(parts_lists_url)
  end

  private

  def cleanup_uploaded_file_params
    return unless params[:parts_list][:file].present?

    file = params[:parts_list][:file]
    params[:parts_list][:original_filename] = file.original_filename

    if file.content_type == 'text/xml'
      params[:parts_list][:bricklink_xml] = file.read
    else
      params[:parts_list][:ldr] = file.read
    end
  end

  def cleanup_lots_params
    return unless params['parts_list']['lots_attributes'].present?

    params['parts_list']['lots_attributes'].each do |lot|
      lot[1].delete('part')
      lot[1].delete('color')
    end
  end

  def set_colors
    @colors = Color.where("bl_name IS NOT NULL AND bl_id IS NOT NULL").order('bl_name ASC')
  end
end
