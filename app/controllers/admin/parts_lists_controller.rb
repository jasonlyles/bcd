# frozen_string_literal: true

class Admin::PartsListsController < AdminController
  before_action :set_colors
  before_action :cleanup_lots_params, only: %i[create update]
  before_action :cleanup_uploaded_file_params, only: %i[create update]

  def index
    @q = PartsList.ransack(params[:q])
    @parts_lists = @q.result.includes(:product, :lots).order('name').page(params[:page]).per(20)
  end

  # GET /parts_lists/new
  def new
    @parts_list = if params[:product_id]
                    PartsList.new(product_id: params[:product_id])
                  else
                    PartsList.new
                  end
    @lots = @parts_list.lots.includes(:part, :color, element: :part).order('parts.name ASC, colors.bl_name ASC')
  end

  # GET /parts_lists/1/edit
  def edit
    @parts_list = PartsList.find(params[:id])
    @lots = @parts_list.lots.includes(element: %i[part color]).order('parts.name ASC, colors.bl_name ASC')
  end

  def show
    @parts_list = PartsList.find(params[:id])

    # This will be the case if the parts list is still being processed.
    if @parts_list.jid?
      redis_total_key = "#{@parts_list.jid}_total"
      redis_counter_key = "#{@parts_list.jid}_counter"
      redis = RedisClient.new
      @total_count = redis.call('GET', redis_total_key)
      @current_count = redis.call('GET', redis_counter_key)
      @lots = []
    else
      @lots = @parts_list.lots.includes(:part, :color, element: %i[part color]).order('parts.name ASC, colors.bl_name ASC')

      if @parts_list.bricklink_xml?
        xml_doc = Nokogiri::XML(@parts_list.bricklink_xml)
        @source_lot_count = xml_doc.xpath('//ITEM').count
        @source_total_quantity = xml_doc.xpath('//ITEM//MINQTY').collect { |c| c.text.to_i }.sum
      elsif @parts_list.ldr?
        # TODO: Get this figured out for LDRs after done with LdrParser class
        @source_lot_count = 0
        @source_total_quantity = 0
      end
    end
  end

  # POST /parts_lists
  def create
    @parts_list = PartsList.new(parts_list_params.except(:file))
    if @parts_list.save
      jid = CreatePartsListJob.perform_async(@parts_list.id)

      if jid.present?
        @parts_list.update(jid:)
        redirect_to([:admin, @parts_list], notice: 'Parts List is being created.')
      else
        # redirect_to([:admin, @parts_list], alert: interaction.errors.present? ? interaction.errors.join('<br/>') : interaction.error.to_s)
        redirect_to([:admin, @parts_list], alert: 'The job was not scheduled. Please wait and try again.')
      end
    else
      flash[:alert] = 'Parts List was NOT created'
      render 'new'
    end
  end

  # PUT /parts_lists/1
  def update
    @parts_list = PartsList.find(params[:id])
    if @parts_list.update(parts_list_params.except(:file))
      BackendNotification.create(message: "#{current_radmin.email} updated the parts list for #{@parts_list.product&.code_and_name || 'undefined product'}. Be sure to email an update to users if necessary.") unless @parts_list.saved_changes.blank? || @parts_list.saved_changes.keys.sort == %w[approved updated_at]
      redirect_to([:admin, @parts_list], notice: 'Parts List was successfully updated.')
    else
      flash[:alert] = 'Parts List was NOT updated'
      render 'edit'
    end
  end

  # DELETE /parts_lists/1
  def destroy
    @parts_list = PartsList.find(params[:id])
    @parts_list.destroy

    flash[:notice] = 'Deleted parts list'
    redirect_back(fallback_location: admin_parts_lists_url)
  end

  # GET /admin/parts_lists/part_swap
  def part_swap; end

  # POST /admin/parts_lists/create_new_elements
  def create_new_elements
    old_part_name = params.dig(:parts_lists, :old_part)
    new_part_name = params.dig(:parts_lists, :new_part)

    interaction = PartsListInteractions::CreateElementsForPartsSwap.run(old_part_name:, new_part_name:)

    if interaction.succeeded?
      @old_part_name = interaction.old_part_name
      @new_part_name = interaction.new_part_name
      @elements = interaction.elements
      @parts_lists = interaction.affected_parts_lists
    else
      @error = interaction.error
    end

    respond_to(&:js)
  end

  # POST /admin/parts_lists/swap_parts
  def swap_parts
    @old_part_name = params['parts_lists']['old_part']
    @new_part_name = params['parts_lists']['new_part']

    interaction = PartsListInteractions::SwapParts.run(old_part_name: @old_part_name, new_part_name: @new_part_name)

    if interaction.succeeded?
      @parts_lists_ids = interaction.affected_parts_lists_ids
    else
      @error = interaction.error
    end

    respond_to(&:js)
  end

  # POST /admin/parts_lists/notify_customers_of_parts_list_update
  def notify_customers_of_parts_list_update
    parts_list_ids = params[:parts_lists][:parts_list_ids].split
    product_ids = PartsList.where(id: parts_list_ids).pluck(:product_id)
    PartsListUpdateNotificationJob.perform_async(product_ids, params[:parts_lists][:message])
    @message = 'Sending parts list update emails'

    respond_to(&:js)
  end

  # This serves just to redirect to the show page, where the right vars are set.
  def parts_list_job_status
    render js: "window.location = '#{admin_parts_list_path(params[:id])}'"
  end

  private

  # Only allow a trusted parameter "white list" through.
  def parts_list_params
    # Be sure to add nested attributes at the end of the list.
    params.require(:parts_list).permit(:name, :product_id, :approved, :file, :file_cache, :remove_file, :original_filename, :bricklink_xml, :ldr, lots_attributes: {})
  end

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
    @colors = Color.where('bl_name IS NOT NULL AND bl_id IS NOT NULL').order('bl_name ASC')
  end
end
