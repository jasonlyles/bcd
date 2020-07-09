ActiveAdmin.register PartsList do
  menu parent: 'Parts Lists', priority: 0
  # config.batch_actions = false
  # config.clear_action_items!
  permit_params :product_id, :approved, :parts, :url, :ldr, :bricklink_xml,
                :parts_list_type, :name, :name_processing,
                lots_attributes: %i[id quantity part_id color_id element_id _destroy] # I don't remember what the url is for

  filter :product
  filter :approved, as: :check_boxes

  index do
    selectable_column
    column :product
    column :name
    bool_column 'BrickLink XML?' do |parts_list|
      parts_list.bricklink_xml.present?
    end
    bool_column 'LDR?' do |parts_list|
      parts_list.ldr.present?
    end
    toggle_bool_column 'Approved?', :approved, success_message: 'Successfully Updated'
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    tabs do
      tab 'Basics' do
        f.inputs do
          f.input :name, label: 'Part list name should be unique for this product'
          para 'Be sure to either enter BrickLink XML or select a .ldr file'
          f.input :bricklink_xml, label: 'BrickLink XML', input_html: { rows: 10, cols: 80 }
          f.input :ldr, as: :file, label: 'OR, Select a .ldr File'
          f.input :product
        end
      end
      # TODO: Try to figure out how to sort by product name:
      tab 'Parts' do
        f.inputs do
          f.has_many :lots, new_record: 'Add Lot' do |lot|
            lot.inputs do
              lot.input :element_id, hint: lot.object.element.present? \
                ? image_tag(lot.object.element.image)
                : content_tag(:span, "no image yet"),
                wrapper_html: {
                  class: 'fl hidden-file-input',
                  style: 'width: 120px; padding-bottom: 0; margin-bottom: 0'
                }
              lot.input :part_id, as: :select, collection: Part.pluck(:name, :id), wrapper_html: { class: 'fl', style: 'width: 400px;' }
              lot.input :color_id, as: :select, collection: Color.pluck(:bl_name, :id), wrapper_html: { class: 'fl', style: 'width: 250px;' }
              lot.input :quantity, wrapper_html: { class: 'fl', style: 'width: 100px;' }
              lot.input :_destroy, as: :boolean, label: 'Delete', wrapper_html: { class: 'fl' }
              lot.input :id, as: :hidden
            end
          end
        end
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :product
      row :name
      row 'BrickLink XML?' do |parts_list|
        parts_list.bricklink_xml.present?
      end
      row '.ldr?' do |parts_list|
        parts_list.ldr.present?
      end
      row :approved
      row 'Unique Parts' do |parts_list|
        parts_list.lots.length
      end
      row 'Total Parts Count' do |parts_list|
        parts_list.lots.map(&:quantity).reduce(&:+)
      end
      row 'Regenerate Sprite Sheet' do |parts_list|
        # Need to notify admin somewhere that sprite sheet needs to be updated, if it needs to be updated.
        render 'regenerate_sprite_sheet_form', parts_list: parts_list
      end
      row 'Parts' do |parts_list|
        render 'parts_list', parts_list: parts_list
      end
    end
    active_admin_comments
  end

  member_action :regenerate_sprite_sheet, method: :post do
    @parts_list = PartsList.find(params[:id])
    @parts_list.regenerate_sprite_sheet

    redirect_to action: :show, id: params[:id]
  end

  # Just a test
  member_action :test_parts_list, method: :get do
    @parts_list = PartsList.find(params[:id])
    @parts_list.spritesheet_css = "https://brickcitydepot-images-dev.s3.amazonaws.com/css_and_spritesheets/107.css"
    #@parts_list.spritesheet_image = "https://brickcitydepot-images-dev.s3.amazonaws.com/css_and_spritesheets/106.png"
  end

  controller do
    def scoped_collection
      if params['action'] == 'index'
        super.includes :product
      else
        super.includes lots: [element: [:part, :color]]
      end
    end

    def create
      create! { admin_parts_lists_path }
      if params['parts_list']['ldr'].present?
        @parts_list.ldr = File.read(params['parts_list']['ldr'].path)
        @parts_list.save
      end
      if @parts_list.valid?
        CreatePartsListJob.do_it(parts_list_id: @parts_list.id)
        flash[:notice] = 'XML/.ldr uploaded and being processed...'
      else
        flash[:notice] = 'There was a problem creating the parts list'
      end
    end

    def update
      if params['parts_list'] && params['parts_list']['lots_attributes']
        params['parts_list']['lots_attributes'].each do |k,v|
          # Use part_id and color_id to find element
          part_id = Part.find(v['part_id']).bl_id
          color_id = Color.find(v['color_id']).ldraw_id
          element = Element.find_or_create_via_external("#{part_id}_#{color_id}")
          params['parts_list']['lots_attributes'][k]['element_id'] = element.id.to_s
        end
      end

      update! { admin_parts_list_path }

      if @parts_list.valid?
        flash[:notice] = 'Parts List updated successfully'
      else
        flash[:notice] = "Please correct errors: #{@parts_list.errors.full_messages.join(', ')}"
      end
    end
  end
end
