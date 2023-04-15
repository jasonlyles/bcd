# frozen_string_literal: true

module ApplicationHelper
  def snippet(text, options = {})
    opts = { word_count: 20 }.merge(options)
    text.split[0..(opts[:word_count] - 1)].join(' ') + (text.split.size > opts[:word_count] ? '...' : '')
  end

  def featured_items
    Product.find_products_for_sale.featured.order(Arel.sql('random()')).first(1)
  end

  def current_month
    Date.today.strftime('%B')
  end

  def current_month_possessive
    "#{current_month}'s"
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def meta_keywords
    t(:keywords, scope: [:meta])
  end

  def meta_description
    t(:description, scope: [:meta])
  end

  def opengraph_metadata
    { image: asset_url('logo_200x200.png'),
      title: "Brick City Depot. The internets' best source for custom Lego instructions.",
      description: 'Brick City Depot sells custom Lego instructions, models and kits. Featuring models based on the Lego Modular Buildings line.',
      app_id: Rails.application.credentials.facebook.app_id,
      site_name: 'Brick City Depot',
      url: request.original_url }
  end

  def host_url
    "#{request.protocol}#{request.env['HTTP_HOST']}"
  end

  def decorate_boolean(value)
    value ? raw('<i class="text-success fas fa-check"></i>') : raw('<i class="text-danger fas fa-times"></i>')
  end

  def decorate_source(value)
    case value
    when 'brick_city_depot'
      image_tag('logo140x89.png', style: 'height: 30px;')
    when 'etsy'
      image_tag('etsy_logo.png', style: 'height: 30px;')
    else
      value.capitalize
    end
  end

  def decorate_order_status(status)
    case status
    when 'COMPLETED'
      raw('<button type="button" class="btn" data-toggle="tooltip" data-placement="top" title="COMPLETED"><i class="text-success fas fa-check"></i></button>')
    when 'INVALID'
      raw('<button type="button" class="btn" data-toggle="tooltip" data-placement="top" title="INVALID"><i class="text-danger fa fa-ban"></i></button>')
    when 'FAILED'
      raw('<button type="button" class="btn" data-toggle="tooltip" data-placement="top" title="FAILED"><i class="text-danger fas fa-times"></i></button>')
    when 'GIFT'
      raw('<button type="button" class="btn" data-toggle="tooltip" data-placement="top" title="GIFT"><i class="text-success fa fa-gift"></i></button>')
    when 'THIRD_PARTY_PENDING_PAYMENT'
      raw('<button type="button" class="btn" data-toggle="tooltip" data-placement="top" title="THIRD_PARTY_PENDING_PAYMENT"><i class="text-primary fa fa-credit-card"></i></button>')
    when 'THIRD_PARTY_PENDING'
      raw('<button type="button" class="btn" data-toggle="tooltip" data-placement="top" title="THIRD_PARTY_PENDING"><i class="text-primary fa fa-hourglass-start"></i></button>')
    when 'THIRD_PARTY_CANCELED'
      raw('<button type="button" class="btn" data-toggle="tooltip" data-placement="top" title="THIRD_PARTY_CANCELED"><i class="text-primary fa fa-ban"></i></button>')
    else
      raw("<button type=\"button\" class=\"btn\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"UNKNOWN: #{status}\"><i class=\"fa fa-question\"></i></button>")
    end
  end

  def status_explanation
    <<-TEXT.squish
      <i class="text-success fas fa-check"></i> COMPLETED: This order is 100% complete. The user can download.<br />
      <i class="text-danger fa fa-ban"></i> INVALID: The IPN returned by Paypal marked this order as INVALID. Check Paypal to see if money came through.<br />
      <i class="text-danger fas fa-times"></i> FAILED: Something happened with this order. If Paypal says the money is there, convert to completed.<br />
      <i class="text-success fa fa-gift"></i> GIFT: User was given these instructions.<br />
      <i class="text-primary fa fa-credit-card"></i> THIRD_PARTY_PENDING_PAYMENT: The 3rd party says the order is complete, pending payment.<br />
      <i class="text-primary fa fa-hourglass-start"></i> THIRD_PARTY_PENDING: The 3rd party says the order has been started, but is not yet complete.<br />
      <i class="text-primary fa fa-ban"></i> THIRD_PARTY_CANCELED: The 3rd party says the order was cancelled. So sad.<br />
      <i class=\"fa fa-question\"></i> UNKNOWN: This is an unknown/unexpected status. We will need to figure this out asap.
    TEXT
  end
end
