class Order < ActiveRecord::Base
  has_many :line_items, :dependent => :destroy
  belongs_to :user

  attr_accessible :request_id, :status, :transaction_id, :user_id, :first_name, :last_name, :address_street_1, :address_street_2,
                  :address_city, :address_state, :address_country, :address_zip, :address_submission_method
  attr_accessor :address_submission_method

  #Need some form of validation, but probably not this, or not the traditional
  #Rails way anyway. Don't want to show these errors to the user.
  #validates :user_id, :presence => true
  #validates :confirmation_number => true
  validates :first_name, :last_name, :address_street_1, :address_city, :address_state, :address_country, :address_zip, presence: true, if: "address_submission_method == 'form'"
  validates :address_zip, length: {is: 5}, if: "address_submission_method == 'form'"
  validates :address_zip, numericality: {only_integer: true}, if: "address_submission_method == 'form'"


  def has_physical_item?
    self.line_items.each do |item|
      if item.product.is_physical_product?
        return true
      end
    end
    return false
  end

  def self.shipping_status_not_complete
    Order.where("shipping_status <> 0").order("created_at DESC")
  end

  def self.shipping_status_complete
    Order.where("shipping_status = 0").order("created_at DESC").limit(10)
  end

  def add_line_items_from_cart(cart)
    cart.cart_items.each do |item|
      li = LineItem.from_cart_item(item)
      line_items << li
    end
  end

  def total_price
    total = 0.0
    self.line_items.each { |item| total += item.total_price }
    total
  end

  def self.all_transactions_for_month(month,year)
    report_date = Date.parse("#{month}/#{year}").strftime("%Y-%m-%d")
    orders = Order.where("created_at >= ? AND created_at < ?","#{report_date}","#{Date.parse("#{report_date}").next_month.strftime("%Y-%m-01")}")
    transactions = []
    orders.each do |order|
      order.line_items.each do |li|
        trans = []
        trans << order.user.email
        trans << order.transaction_id
        trans << order.request_id
        trans << order.status
        trans << order.created_at.strftime("%m/%d/%Y")
        trans << li.product.code_and_name
        trans << li.quantity
        trans << li.total_price.to_s
        transactions << trans
      end
    end
    transactions
  end

  def self.transaction_csv(transactions)
    CSV.generate do |csv|
      csv << ["Email","Transaction ID","Request ID","Status","Date","Product","Qty","Total Price"]
      transactions.each do |trans|
        csv << trans
      end
    end
  end

  #Return an array of all download links in the format:
  # [["Colonial Revival PDF", link],["Colonial Revival HTML Parts List", link]]
  def get_download_links
    links = []
    self.line_items.each do |line_item|
      product = Product.find(line_item.product_id)
      if product.includes_instructions?
        product_name = product.code_and_name
        html_list = PartsList.get_list(product.parts_lists, 'html')
        xml_list = PartsList.get_list(product.parts_lists, 'xml')
        if html_list
          links << ["#{product_name} HTML Parts List","/guest_download_parts_list/#{html_list.id}/#{self.id}"]
        end
        if xml_list
          links << ["#{product_name} XML Parts List for Bricklink Wanted List Feature","/guest_download_parts_list/#{xml_list.id}/#{self.id}"]
        end
        download = Download.where(["user_id=? and product_id=?",self.user_id,product.id]).first_or_create(:download_token => SecureRandom.hex(20), :product_id => product.id, :user_id => self.user_id)
        guid = self.user.guid
        links << ["#{product_name} PDF", "/guest_download?id=#{guid}&token=#{download.download_token}"]
      end
    end
    links
  end

  def get_link_to_downloads
    link = "#{Rails.application.config.web_host}/download_link_error" #Default to this, and overwrite if there is a transaction ID and request ID
    if !self.transaction_id.blank? && !self.request_id.blank?
      link = "#{Rails.application.config.web_host}/guest_downloads?tx_id=#{self.transaction_id}&conf_id=#{self.request_id}"
    end
    link
  end
end
