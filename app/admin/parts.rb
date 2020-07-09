ActiveAdmin.register Part do
  menu parent: 'Parts Lists', priority: 2, label: 'Parts'
  config.batch_actions = false
  permit_params :bl_id, :ldraw_id, :lego_id, :name, :check_bricklink,
                :check_rebrickable, :is_lsynth, :is_obsolete, :alternate_nos

  filter :bl_id_or_ldraw_id_or_lego_id_cont, as: :string, label: 'BrickLink/Lego/LDraw ID'
  filter :name
  filter :check_bricklink, as: :check_boxes
  filter :check_rebrickable, as: :check_boxes
  filter :is_lsynth, as: :check_boxes
  filter :is_obsolete, as: :check_boxes

  index do
    column 'BrickLink ID' do |part|
      link_to part.bl_id, "https://www.bricklink.com/v2/catalog/catalogitem.page?P=#{part.bl_id}", target: '_blank'
    end
    column 'LDraw ID' do |part|
      link_to part.ldraw_id, "https://guide.lugnet.com/partsref/search.cgi?q=#{part.ldraw_id}", target: '_blank'
    end
    column 'Rebrickable Link' do |part|
      link_to part.bl_id, "https://rebrickable.com/parts/#{part.bl_id}", target: '_blank'
    end
    column 'Name' do |part|
      link_to part.name, admin_part_path(part.id)
    end
    bool_column 'Check BL?', &:check_bricklink
    bool_column 'Check Rebrickable?', &:check_rebrickable
    bool_column 'LSynth?', &:is_lsynth
    bool_column 'Obsolete?', &:is_obsolete
    actions
  end

  show do
    tabs do
      tab 'General Info' do
        attributes_table do
          row 'Name', &:name
          row 'Bricklink ID', &:bl_id
          row 'Ldraw ID', &:ldraw_id
          row 'Lego ID', &:lego_id
          row 'BrickOwl IDs', &:brickowl_ids
          row 'Alternate Numbers', &:alternate_nos
          row 'Date Range' do |part|
            "#{part.year_from}-#{part.year_to}"
          end
          bool_row 'Check Bricklink?', &:check_bricklink
          bool_row 'Check Rebrickable?', &:check_rebrickable
          bool_row 'LSynth Part?', &:is_lsynth
          bool_row 'Obsolete?', &:is_obsolete
        end
      end
      tab 'Images' do
        attributes_table do
          row 'Images' do |part|
            render 'images', part: part
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :bl_id, label: 'BrickLink ID'
      f.input :ldraw_id, label: 'LDraw ID', :input_html => { :disabled => true }
      f.input :lego_id, label: 'Lego ID'
      f.input :alternate_nos, as: :string, label: 'Alternate Number'
      f.input :name, label: 'Name', wrapper_html: { style: 'width: 400px;' }
      f.input :check_bricklink, label: 'Check Bricklink?'
      f.input :check_rebrickable, label: 'Check Rebrickable?'
      f.input :is_lsynth, label: 'LSynth Part?'
      f.input :is_obsolete, label: 'Obsolete?'
    end
    f.actions
  end
end
