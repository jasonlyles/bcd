ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column span: 4 do
        panel 'Notifications' do
          div class: 'nice-padding' do
            'TODO'
          end
        end
      end
      column do
        panel 'Month to Date' do
          sales_summary = Order.month_to_date_summary
          div class: 'nice-padding' do
            text_node "<strong>Items sold:</strong> #{sales_summary[:total_item_count]}".html_safe
            br
            text_node "<strong>Total Amount:</strong> #{number_to_currency(sales_summary[:total_price])}".html_safe
          end
        end
      end
    end
    br
    columns do
      column do
        panel 'Recent Orders' do
          table_for Order.order('created_at desc').includes(:user, :instant_payment_notifications, line_items: [product: [:product_type]]).last(10) do
            column('User') { |order| link_to order.user.email, admin_user_path(order.user_id) }
            column('Order Date', &:created_at)
            column('Transaction ID') { |order| link_to order.transaction_id, admin_order_path(order.id) }
            column('Status', &:status)
            column('Source') { |_order| 'brickcitydepot.com' }
            column('IPN?') { |order| order.instant_payment_notifications.present? }
            column('Includes Physical Item?', &:has_physical_item?)
            column('Total Items', &:total_item_count)
            column('Total Price') { |order| number_to_currency(order.total_price) }
          end
        end
      end
    end
    br
    columns do
      column do
        panel 'Live Advertising Campaigns' do
          table_for AdvertisingCampaign.live_campaigns.order('created_at desc') do
            column('Partner') { |campaign| link_to campaign.partner.name, admin_partner_path(campaign.partner_id) }
            column('Reference Code') { |campaign| link_to campaign.reference_code, admin_advertising_campaign_path(campaign.id) }
            column('Description') { |campaign| snippet(campaign.description, word_count: 10) }
            column('Created', &:created_at)
          end
        end
      end
      column do
        panel 'Last 10 Email Campaigns' do
          table_for EmailCampaign.order('created_at desc').last(10) do
            column('Description') { |campaign| link_to snippet(campaign.description, word_count: 10), admin_email_campaign_path(campaign.id) }
            column('Emails Sent', &:emails_sent)
            column('Effectiveness Ratio') { |campaign| "#{campaign.effectiveness_ratio}%" }
            column('Created', &:created_at)
          end
        end
      end
    end
    br
  end # content
end
