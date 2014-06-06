module ApplicationHelper
  def snippet(text,options={})
    opts = {:word_count => 20}.merge(options)
    text.split[0..(opts[:word_count]-1)].join(" ") + (text.split.size > opts[:word_count] ? "..." : "")
  end

  def featured_item
    #This might not be a pretty way to get a random product, but it would take us having a lot of products to make this slow, I would guess
    @products = Product.find_products_for_sale
    ids = @products.collect{|product| product.id}
    random_array_index = rand(ids.length)
    product_id = ids[random_array_index]
    if product_id.blank?
      product = nil
    else
      product = Product.find(product_id)
    end
    product
  end

  def h1(content)
    content_for(:h1) {content}
  end

  def h2(content)
    content_for(:h2) {content}
  end

  def title(page_title)
    content_for(:title){page_title}
  end

  def meta_keywords
    t(:keywords, :scope => [:meta])
  end

  def meta_description
    t(:description, :scope => [:meta])
  end

  def opengraph_metadata
    {:image => asset_url('logo_200x200.png'),
     :title => "Brick City Depot. The internets' best source for custom Lego instructions.",
     :description => 'Brick City Depot sells custom Lego instructions, models and kits. Featuring models based on the Lego Modular Buildings line.',
     :app_id => ENV['BCD_FACEBOOK_APP_ID'],
     :site_name => 'Brick City Depot',
     :url => request.original_url}
  end

  def string_to_snake_case(string)
    new_string = string.downcase
    new_string = new_string.gsub(' ','_')
    new_string
  end
end
