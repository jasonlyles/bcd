ActiveAdmin.register Product do
  batch_action :destroy, false
  batch_action :discount, form: {
    discount_percentage: :text
  } do |ids, inputs|
    batch_action_collection.find(ids).each do |product|
      product.discount_percentage = inputs['discount_percentage']
      product.save
    end
    redirect_to collection_path, notice: "Discount Set to #{inputs['discount_percentage']}% for #{ids.length} Product(s)"
  end

  menu parent: "Products", priority: 3
  permit_params :name, :product_type_id, :category_id, :subcategory_id,
                :product_code, :description, :designer, :alternative_build,
                :ready_for_public, :pdf, :featured, :tweet, :youtube_url,
                :discount_percentage, :price, :free, :quantity,
                images_attributes: [:id, :url, :_destroy]

  includes :category, :subcategory, :product_type

  filter :category
  filter :subcategory
  filter :product_type
  filter :name
  filter :product_code
  filter :discount_percentage
  filter :price
  filter :ready_for_public, label: 'Live?', as: :check_boxes
  filter :free, label: 'Free?', as: :check_boxes
  filter :quantity
  filter :alternative_build, label: 'Alternative Build?', as: :check_boxes
  filter :featured, label: 'Featured?', as: :check_boxes
  filter :designer, as: :select, collection: -> { Product.all.pluck(:designer).uniq }

  index do
    selectable_column
    column 'Product' do |product|
      link_to "#{product.product_code} #{product.name}", admin_product_path(product.id)
    end
    column 'Type' do |product|
      product.product_type.name
    end
    column 'Cat/Subcat' do |product|
      "#{product.category.name}/#{product.subcategory.name}"
    end
    column 'Qty' do |product|
      product.is_digital_product? ? 'N/A' : product.quantity
    end
    column 'Images' do |product|
      product.images.count
    end
    column 'Discount %' do |product|
      product.discount_percentage&.to_i
    end
    column 'Price' do |product|
      number_to_currency(product.price)
    end
    column 'Live?', &:ready_for_public
    actions defaults: true do |product|
      link_to 'Clone', duplicate_admin_product_path(product,product)
    end
  end

  show do
    tabs do
      tab 'General Info' do
        attributes_table do
          row :name
          row 'Product Type' do |product|
            link_to product.product_type.name, admin_product_type_path(product.product_type_id)
          end
          row 'Category' do |product|
            link_to product.category.name, admin_category_path(product.category_id)
          end
          row 'Subcategory' do |product|
            link_to product.subcategory.name, admin_subcategory_path(product.subcategory_id)
          end
          row :product_code
          row :description
          row 'Designer' do |product|
            product.designer.humanize
          end
          row :ready_for_public
          row :alternative_build
        end
      end
      tab 'PDF/Parts Lists' do
        attributes_table do
          row :pdf
          row 'Parts Lists' do |product|
            product.parts_lists.collect(&:parts_list_type)&.join(', ')
          end
        end
      end
      tab 'Advertising/Social Media' do
        attributes_table do
          row :featured
          row :tweet
          row 'Youtube url' do |product|
            render 'youtube', { product: product }
          end
        end
      end
      tab 'Images' do
        attributes_table do
          row 'Images' do |product|
            render 'images', { product: product }
          end
        end
      end
      tab 'Pricing' do
        attributes_table do
          row 'Price' do |product|
            number_to_currency(product.price)
          end
          row :free
          row 'Discount %' do |product|
            "#{product.discount_percentage.to_i}%"
          end
          row 'Quantity' do |product|
            product.is_digital_product? ? 'N/A' : product.quantity
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    tabs do
      tab 'General Info' do
        f.inputs do
          f.input :name
          f.input :product_type_id, as: :select, collection: ProductType.all, include_blank: 'Select Product Type'
          f.input :category_id, as: :select, collection: Category.all, include_blank: 'Select Category'
          f.input :subcategory_id, as: :select, collection: Subcategory.all, include_blank: 'Select Subcategory'
          f.input :product_code, label: 'Product Code *, **'
          f.input :description, label: 'Description (min 100 characters)'
          f.input :designer, as: :select, collection: Product.pluck(:designer).uniq, include_blank: 'Select Designer'
          f.input :alternative_build
          f.input :ready_for_public, label: 'Ready for public? ***'
        end
        render 'footnotes'
      end
      tab 'PDF/Parts Lists' do
        if f.object.is_digital_product?
          f.inputs do
            f.input :pdf, label: 'PDF'
          end
        else
          para "File upload not necessary"
        end
      end
      tab 'Advertising/Social Media' do
        f.inputs do
          f.input :featured, label: 'Featured (This means this product will be featured on the front page)'
          f.input :tweet, label: 'Tweet (This is the text that will be tweeted out by the user by default, should they tweet)'
          f.input :youtube_url, label: 'Youtube Video ID (If full url is http://www.youtube.com/watch?v=oavMtUWDBTM I just want oavMtUWDBTM)'
        end
      end
      tab 'Images' do
        f.inputs do
          f.has_many :images, new_record: 'Add Image', allow_destroy: true do |image|
            image.inputs do
              if image.object.url.present?
                image_tag(image.object.url.url, class: 'medium')
              else
                image.template.concat "<div class='image-preview'><img id='img_prev' src='#' alt='your image' class='medium hidden img-preview'/></div>".html_safe
                image.input :url, as: :file, label: 'Image', hint: 'Images should be 700px x 700px', input_html: {class: 'nested-images-upload'}
                image.input :url_cache, as: :hidden
              end
            end
          end
        end
      end
      tab 'Pricing' do
        f.inputs do
          f.input :discount_percentage, label: 'Percentage off, expressed as an integer. i.e. 25 would mean 25% off (This is not fully functional yet)'
          f.input :price
          f.input :free
          f.input :quantity, label: 'Quantity (Only fill this out if product is a physical item.)'
        end
      end
    end
    f.actions
  end

  member_action :duplicate, method: :get do
    @product = resource.dup
    render :new, layout: false
  end
end
