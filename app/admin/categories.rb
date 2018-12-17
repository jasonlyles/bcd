ActiveAdmin.register Category do
  config.batch_actions = false
  menu parent: 'Products', priority: 1
  permit_params :name, :description, :ready_for_public, :image, :image_cache

  filter :name
  filter :ready_for_public

  index do
    column 'Name' do |category|
      link_to category.name, admin_category_path(category.id)
    end
    column 'Description' do |category|
      snippet(category.description, word_count: 10)
    end
    column :ready_for_public
    actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :ready_for_public
      row 'Image' do |category|
        image_tag(category.image) if category.image?
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :description
      f.input :ready_for_public
      if category.image?
        render 'admin/shared/images', model: category
        f.input :remove_image, as: :boolean, label: 'Delete Image'
      else
        f.input :image, as: :file
      end
      f.input :image_cache, as: :hidden
    end
    f.actions
  end
end
