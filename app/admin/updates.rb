ActiveAdmin.register Update do
  menu parent: 'Marketing', priority: 3
  config.batch_actions = false
  permit_params :title, :description, :body, :live, :link, :image, :image_cache

  filter :title
  filter :description
  filter :live
  filter :link

  index do
    column 'Title' do |update|
      link_to update.title, admin_update_path(update.id)
    end
    column 'Description' do |update|
      snippet(update.description, word_count: 10) if update.description
    end
    toggle_bool_column :live
    column :link
    column 'Image?', &:image?
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :title
      row :description
      row :body
      row :live
      row :link
      row :created_at
      row :updated_at
      row 'Image' do |update|
        render 'admin/shared/images', model: update
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :title, placeholder: 'Amsterdam Sale!'
      f.input :description, placeholder: 'Everything Amsterdam is on sale!', hint: 'This is not currently used'
      f.input :body, hint: 'This is not currently used'
      f.input :link, hint: 'Link (Where BCD will go to when user clicks on the image.) Example:. To go to FAQ, make the link look like this: /faq', placeholder: '/faq'
      if update.image?
        render 'admin/shared/images', model: update
        f.input :remove_image, as: :boolean, label: 'Delete Image'
      else
        f.input :image, as: :file
      end
      f.input :image_cache, as: :hidden
    end
    render 'footnote'
    f.actions
  end
end
