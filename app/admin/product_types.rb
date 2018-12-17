ActiveAdmin.register ProductType do
  config.batch_actions = false
  menu parent: 'Products', priority: 0
  permit_params :name, :description, :comes_with_title, :comes_with_description, :digital_product, :ready_for_public

  filter :name
  filter :ready_for_public
  filter :digital_product

  index do
    column 'Name' do |product_type|
      link_to product_type.name, admin_product_type_path(product_type.id)
    end
    column :ready_for_public
    column :digital_product
    actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row "'Comes with' title", &:comes_with_title
      row "'Comes with' description", &:comes_with_description
      row :ready_for_public
      row :digital_product
      # TODO: Maybe show image in here. If I don't use the image any more, then drop it from the model and unmount the uploader.
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name, placeholder: 'Printed Tiles'
      f.input :description, placeholder: 'Printed tiles are great for helping to decorate your...'
      f.input :comes_with_title, label: "'Comes with' Title", placeholder: 'What do I get with a...'
      f.input :comes_with_description, label: "'Comes with' Description", hint: '(What does the product come with? Be sure to give a complete description)', placeholder: 'You get a bag of printed tiles...'
      f.input :digital_product
      f.input :ready_for_public
    end
    f.actions
  end
end
