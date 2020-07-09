ActiveAdmin.register Subcategory do
  config.batch_actions = false
  menu parent: 'Products', priority: 2
  permit_params :name, :description, :ready_for_public, :code, :category_id

  filter :name
  filter :category
  filter :ready_for_public

  index do
    column 'Name' do |subcategory|
      link_to subcategory.name, admin_subcategory_path(subcategory.id)
    end
    column 'Description' do |subcategory|
      snippet(subcategory.description, word_count: 10) if subcategory.description.present?
    end
    column :category
    column :code
    column :ready_for_public
    actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :category
      row :code
      row :ready_for_public
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :description
      f.input :category
      f.input :code
      f.input :ready_for_public
    end
    f.actions
  end

  controller do
    def scoped_collection
      if params['action'] == 'index'
        super.includes :category
      else
        super
      end
    end
  end
end
