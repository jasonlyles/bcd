# frozen_string_literal: true

require 'carrierwave'

CarrierWave.configure do |config|
  config.fog_directory = 'brickcitydepot-assets'
end

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://brickcitydepot.com'

# The directory to write sitemaps to locally
SitemapGenerator::Sitemap.public_path = 'tmp/'

# Instance of `SitemapGenerator::WaveAdapter`
SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new

# The remote host where your sitemaps will be hosted
SitemapGenerator::Sitemap.sitemaps_host = 'https://brickcitydepot-assets.s3.amazonaws.com'

SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.include_root = false

SitemapGenerator.verbose = false

SitemapGenerator::Sitemap.create do
  add '/', priority: 0.9, changefreq: 'daily', images: [{
    loc: 'https://brickcitydepot-images.s3.amazonaws.com/logo180x115.png',
    title: 'Brick City Depot',
    caption: 'Brick City Depot'
  }]
  add contact_path, priority: 0.8, changefreq: 'yearly'
  add terms_of_service_path, changefreq: 'yearly'
  add privacy_policy_path, changefreq: 'yearly'
  add coppa_policy_path, changefreq: 'yearly'
  add cookies_path, changefreq: 'yearly'
  add faq_path, priority: 0.8, changefreq: 'monthly'
  add new_user_tutorial_path, changefreq: 'yearly'
  add store_instructions_path, priority: 0.8, changefreq: 'monthly'
  add store_kits_path, changefreq: 'monthly'
  add store_models_path, changefreq: 'monthly'
  add store_path, priority: 0.8, changefreq: 'weekly'
  add '/users/sign_in', priority: 0.8, changefreq: 'monthly'
  add '/users/sign_up', priority: 0.8, changefreq: 'monthly'

  Category.find_each do |category|
    add "store/products/instructions/#{category.name}", priority: 0.7, changefreq: 'monthly' unless category.name == 'Retired'
  end

  Product.ready.find_each do |product|
    if product.main_image.nil?
      add("/#{product.product_code}/#{product.name.to_snake_case}", priority: 0.6, changefreq: 'weekly')
    else
      add("/#{product.product_code}/#{product.name.to_snake_case}", priority: 0.6, changefreq: 'weekly', images: [{
            loc: product.main_image.to_s,
            title: "Brick City Depot #{product.code_and_name}",
            caption: "Brick City Depot #{product.code_and_name}"
          }])
    end
  end
end
