ActiveAdmin.register InstantPaymentNotification do
  menu parent: 'Orders', priority: 1
  config.batch_actions = false
  config.clear_action_items!

  filter :created_at
  filter :payment_status, as: :select, collection: -> { InstantPaymentNotification.pluck(:payment_status).uniq }
  filter :payer_email
  filter :request_id, label: 'Request ID'
  filter :txn_id, label: 'Transaction ID'
  filter :order_id, label: 'Order ID'
  filter :processed
  filter :verify_sign
  filter :notify_version, as: :select, collection: -> { InstantPaymentNotification.pluck(:notify_version).uniq }

  index do
    column :payer_email
    column :payment_status
    column 'Request ID' do |ipn|
      link_to ipn.request_id, admin_instant_payment_notification_path(ipn.id)
    end
    column 'Transaction ID' do |ipn|
      link_to ipn.txn_id, admin_instant_payment_notification_path(ipn.id)
    end
    column :order
    column :processed
    column :created_at
    actions defaults: false do |ipn|
      link_to t('active_admin.view'), admin_instant_payment_notification_path(ipn)
    end
  end

  show do
    attributes_table do
      row :payer_email
      row :payment_status
      row 'Request ID', &:request_id
      row 'Transaction ID', &:txn_id
      row :verify_sign
      row :order
      row :processed
      row :notify_version
      row 'Created At/Updated At' do |ipn|
        "#{ipn.created_at} / #{ipn.updated_at}"
      end
    end
    attributes_table title: 'Instant Payment Notification Params' do
      instant_payment_notification.params.each do |key, _value|
        row key.to_sym do |template|
          template[:params][key]
        end
      end
    end
    active_admin_comments
  end
end
