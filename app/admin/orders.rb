ActiveAdmin.register Order do
  menu parent: 'Orders', priority: 0
  config.batch_actions = false
  actions :all, except: %i[destroy new]
  permit_params :first_name, :last_name, :transaction_id, :request_id, :status,
                :shipping_status, :address_name, :address_street_1, :address_street_2,
                :address_city, :address_state, :address_zip, :address_country

  filter :created_at, label: 'Order Date'
  filter :user_id, as: :search_select_filter, fields: [:email], display_name: 'email', width: '100%', minimum_input_length: 3
  filter :transaction_id_or_request_id_cont, as: :string, label: 'Request ID or Transaction ID'
  filter :status, as: :select, collection: -> { Order.all.pluck(:status).uniq }
  filter :shipping_status, as: :select, collection: -> { Order.all.pluck(:shipping_status).uniq }
  filter :has_instant_payment_notifications_in,
         as: :select,
         label: 'Has IPN?',
         collection: proc { %w[true false] }
  filter :has_physical_items_in,
         as: :select,
         label: 'Has Physical Item?',
         collection: proc { %w[true false] }

  index do
    column :user
    column 'Order Date', &:created_at
    column 'Transaction ID/Request ID' do |order|
      "#{link_to order.transaction_id, admin_order_path(order.id)} #{link_to order.request_id, admin_order_path(order.id)}".html_safe
    end
    column :status
    column 'Shipping Status' do |order|
      order.has_physical_item? ? order.shipping_status : 'N/A'
    end
    column 'IPN?' do |order|
      order.instant_payment_notifications.present?
    end
    column 'Order Total' do |order|
      number_to_currency(order.total_price)
    end
    actions
  end

  show do
    tabs do
      tab 'General Info' do
        attributes_table do
          row :user
          row 'Name' do |order|
            "#{order.first_name} #{order.last_name}"
          end
          row 'Transaction ID / Request ID' do |order|
            "#{order.transaction_id} / #{order.request_id}"
          end
          row 'Order Status', &:status
          row 'Shipping Status' do |order|
            order.has_physical_item? ? order.shipping_status : 'N/A'
          end
          row 'Order Date / Order Last Updated' do |order|
            "#{order.created_at} / #{order.updated_at}"
          end
        end
        render 'admin/orders/line_items', line_items: order.line_items, order: order
      end
      if order.has_physical_item?
        tab 'Address' do
          attributes_table do
            row :address_name
            row 'Address' do |order|
              address = <<-ADDRESS
                #{order.address_street_1}<br />
                #{order.address_street_2}<br />
                #{order.address_city}, #{order.address_state} #{order.address_zip}<br />
                #{order.address_country}
              ADDRESS
              address.html_safe
            end
          end
        end
      end
      tab 'Instant Payment Notifications' do
        render 'admin/orders/instant_payment_notifications', instant_payment_notifications: order.instant_payment_notifications
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    tabs do
      tab 'General Info' do
        f.inputs do
          f.input :first_name
          f.input :last_name
          f.input :transaction_id
          f.input :request_id
          f.input :status, as: :select, collection: Order.all.pluck(:status).uniq, include_blank: 'Select Status'
          f.input :shipping_status, as: :select, collection: [['Completed', 0], ['Shipped', 1], ['Ready', 2], ['Pending', 3]], include_blank: 'Select Shipping Status'
        end
      end
      tab 'Address' do
        f.inputs do
          f.input :address_name
          f.input :address_street_1
          f.input :address_street_2
          f.input :address_city
          f.input :address_state
          f.input :address_zip
          f.input :address_country
        end
      end
    end
    f.actions
  end
end
