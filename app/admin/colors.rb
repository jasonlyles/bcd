ActiveAdmin.register Color do
  menu parent: 'Parts Lists', priority: 1, label: 'Colors'
  config.batch_actions = false
  config.sort_order = 'name_asc'
  actions :all, except: %i[destroy]
  permit_params :bl_id, :ldraw_id, :lego_id, :name, :bl_name, :lego_name, :ldraw_rgb, :rgb

  filter :bl_id_or_ldraw_id_or_lego_id_eq, as: :string, label: 'BrickLink/Lego/LDraw ID'
  filter :name_or_bl_name_or_lego_name_cont, as: :string, label: 'BrickLink/Lego/LDraw Name'

  index do
    column 'BrickLink/Lego/LDraw ID' do |color|
      "#{color.bl_id}/#{color.lego_id}/#{color.ldraw_id}"
    end
    column 'BrickLink Name' do |color|
      link_to color.bl_name, admin_color_path(color.id)
    end
    column 'Lego Name' do |color|
      link_to color.lego_name, admin_color_path(color.id)
    end
    column 'LDraw Name' do |color|
      link_to color.name, admin_color_path(color.id)
    end
    column 'Color' do |color|
      div style: "background-color: ##{color.ldraw_rgb};padding: 15px;" do
      end
    end
    actions
  end

  show do
    attributes_table do
      row 'Bricklink ID', &:bl_id
      row 'Ldraw ID', &:ldraw_id
      row 'Lego ID', &:lego_id
      row 'Bricklink Name', &:bl_name
      row 'Ldraw Name', &:name
      row 'Lego Name', &:lego_name
      row 'Ldraw RGB' do |color|
        div do
          "##{color.ldraw_rgb}"
        end
        div style: "background-color: ##{color.ldraw_rgb};padding: 15px" do
        end
      end
      row 'RGB' do |color|
        div do
          "##{color.rgb}"
        end
        div style: "background-color: ##{color.rgb};padding: 15px;" do
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :bl_id, label: 'BrickLink ID'
      f.input :ldraw_id, label: 'LDraw ID'
      f.input :lego_id, label: 'Lego ID'
      f.input :bl_name, label: 'BrickLink Name'
      f.input :name, label: 'LDraw Name'
      f.input :lego_name, label: 'Lego Name'
      f.input :ldraw_rgb, label: 'LDraw RGB'
      f.input :rgb, label: 'RGB'
    end
    f.actions
  end
end
