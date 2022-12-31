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
end
