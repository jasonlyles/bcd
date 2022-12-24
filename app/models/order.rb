# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items
  belongs_to :user, optional: true
  has_many :instant_payment_notifications

  # attr_accessible :request_id, :status, :transaction_id, :user_id, :first_name, :last_name,
  # :address_street1, :address_street2, :address_city, :address_state, :address_country,
  # :address_zip, :address_submission_method
  attr_accessor :address_submission_method

  # Need some form of validation, but probably not this, or not the traditional
  # Rails way anyway. Don't want to show these errors to the user.
  # validates :user_id, :presence => true
  # validates :confirmation_number => true
  validates :first_name, :last_name, :address_street1, :address_city, :address_state, :address_country,
            :address_zip, presence: true, if: -> { :address_submission_method == 'form' }
  validates :address_zip, length: { is: 5 }, if: -> { :address_submission_method == 'form' }
  validates :address_zip, numericality: { only_integer: true }, if: -> { :address_submission_method == 'form' }

  def includes_physical_item?
    line_items.includes(product: [:product_type]).each do |item|
      return true if item.product.physical_product?
    end
    false
  end

  def includes_digital_item?
    items = retrieve_digital_items
    items.blank? ? false : true
  end

  def retrieve_digital_items
    items = []
    line_items.each do |item|
      items << item if item.product.digital_product?
    end
    items
  end

  def self.shipping_status_not_complete
    Order.where('shipping_status <> 0').order('created_at DESC')
  end

  def self.shipping_status_complete
    Order.where('shipping_status = 0').order('created_at DESC').limit(10)
  end

  def add_line_items_from_cart(cart)
    cart.cart_items.each do |item|
      li = LineItem.from_cart_item(item)
      line_items << li
    end
  end

  def total_price
    total = 0.0
    line_items.each { |item| total += item.total_price }
    total
  end

  # rubocop:disable Metrics/AbcSize
  def self.all_transactions_for_month(month, year)
    report_date = Date.parse("#{month}/#{year}").strftime('%Y-%m-%d')
    orders = Order.where('created_at >= ? AND created_at < ?', report_date.to_s, Date.parse(report_date.to_s).next_month.strftime('%Y-%m-01').to_s)
    transactions = []
    orders.each do |order|
      order.line_items.each do |li|
        trans = []
        trans << order.user.email
        trans << order.transaction_id
        trans << order.request_id
        trans << order.status
        trans << order.created_at.strftime('%m/%d/%Y')
        trans << li.product.code_and_name
        trans << li.quantity
        trans << li.total_price.to_s
        transactions << trans
      end
    end
    transactions
  end
  # rubocop:enable Metrics/AbcSize

  def self.transaction_csv(transactions)
    CSV.generate do |csv|
      csv << ['Email', 'Transaction ID', 'Request ID', 'Status', 'Date', 'Product', 'Qty', 'Total Price']
      transactions.each do |trans|
        csv << trans
      end
    end
  end

  # Return an array of all download links in the format:
  # [["Colonial Revival PDF", link],["Colonial Revival HTML Parts List", link]]
  def retrieve_download_links
    return unless status.casecmp('COMPLETED').zero?

    links = []
    line_items.each do |line_item|
      product = Product.find(line_item.product_id)
      next unless product.includes_instructions?

      product_name = product.code_and_name
      guid = user.guid
      download = Download.where(['user_id=? and product_id=?', user_id, product.id])
                         .first_or_create(download_token: SecureRandom.hex(20), product_id: product.id, user_id: user_id)
      product.parts_lists.each { |pl| links << ["#{product_name} Parts List", "/parts_lists/#{pl.id}?user_guid=#{guid}&token=#{download.download_token}"] }

      links << ["#{product_name} PDF", "/guest_download?id=#{guid}&token=#{download.download_token}"]
    end
    links
  end

  def retrieve_link_to_downloads
    web_host = Rails.application.config.web_host
    link = "#{web_host}/download_link_error" # Default to this, and overwrite if there is a transaction ID and request ID
    link = "#{web_host}/guest_downloads?tx_id=#{transaction_id}&conf_id=#{request_id}" if !transaction_id.blank? && !request_id.blank?
    link
  end
end
