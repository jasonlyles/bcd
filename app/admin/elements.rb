ActiveAdmin.register Element do
  menu parent: 'Parts Lists', priority: 3, label: 'Elements'
  config.batch_actions = false
  permit_params :part_id, :color_id, :image, :image_cache, :guid, :remove_image

  filter :part_id, as: :search_select_filter, fields: [:name], display_name: 'name', width: '100%', minimum_input_length: 3
  filter :color_id, as: :search_select_filter, fields: [:bl_name], display_name: 'name', width: '100%', minimum_input_length: 3
  filter :guid
  filter :has_image_in,
         as: :select,
         label: 'Has Image?',
         collection: proc { %w[true false] }

  index do
    column 'Part' do |element|
      link_to element.part.name.to_s, admin_part_path(element.part_id)
    end
    column 'Color' do |element|
      link_to element.color.bl_name.to_s, admin_color_path(element.color_id)
    end
    column 'Image Url' do |element|
      if element.image.present?
        link_to 'Link to Image', element.image.url, target: '_blank'
      end
    end
    column :guid
    actions
  end

  show do
    attributes_table do
      row 'Part' do |element|
        if element.part.name.present?
          link_to element.part.name, admin_part_path(element.part_id)
        else
          link_to 'Please give this part a name', admin_part_path(element.part_id)
        end
      end
      row 'Color' do |element|
        element.color.name
      end
      row 'Image Url', &:image
      row 'Original Image URL' do |element|
        link_to element.original_image_url, element.original_image_url, target: '_blank'
      end
      row 'GUID', &:guid
      row 'Image' do |element|
        render 'image', { element: element }
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :part_id, as: :search_select, fields: [:name], display_name: 'name', minimum_input_length: 3, wrapper_html: { style: 'width: 400px;' }
      f.input :color_id, as: :search_select, fields: [:name], display_name: 'name', minimum_input_length: 3, wrapper_html: { style: 'width: 400px;' }
      if element.image.present?
        render 'admin/shared/images', model: element
        f.input :remove_image, as: :boolean, label: 'Delete Image'
      else
        f.input :image, as: :file
      end
      f.input :image_cache, as: :hidden
    end
    f.actions
  end

  member_action :refresh_image, method: :post do
    # TODO: Move most of this to element.rb and extract the common functionality
    @element = Element.find(params[:id])
    part = @element.part
    if params[:source] == 'rebrickable'
      part.check_rebrickable = true
      part.save!
      @element.update_from_rebrickable(@element.part.ldraw_id, @element.color.ldraw_id)
      # If we couldn't get anything back with our ldraw_id, let's try the bl_id
      if @element.part.check_rebrickable?
        @element.update_from_rebrickable(@element.part.bl_id, @element.color.ldraw_id)
      end
      # If we couldn't get anything back with our bl_id, let's try an alternate number
      if @element.part.check_rebrickable?
        @element.update_from_rebrickable(@element.part.alternate_nos, @element.color.ldraw_id)
      end
    end
    if params[:source] == 'bricklink'
      part.check_bricklink = true
      part.save!
      @element.update_from_bricklink(@element.part.bl_id, @element.color.ldraw_id)
      # If we couldn't get anything back with our bl_id, let's try our ldraw_id
      if @element.part.check_bricklink?
        @element.update_from_bricklink(@element.part.ldraw_id, @element.color.ldraw_id)
      end
      # If we couldn't get anything back with our ldraw_id, let's try an alternate number
      if @element.part.check_bricklink?
        @element.update_from_bricklink(@element.part.alternate_nos, @element.color.ldraw_id)
      end
    end

    @element.save! if @element.store_image

    redirect_to action: :show, id: params[:id]
  end

  controller do
    def scoped_collection
      if params['action'] == 'index'
        super.includes :part, :color
      else
        super
      end
    end
  end
end
