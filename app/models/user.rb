class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :email_preference, :account_status, :tos_accepted, :referrer_code

  has_many :orders
  has_many :line_items, through: :orders
  has_many :products, through: :line_items
  has_many :authentications, dependent: :destroy
  has_many :downloads
  has_one :cart

  validates :tos_accepted, acceptance: { accept: true }

  before_create :set_up_guids
  before_save do
    email.downcase!
  end

  enum account_status: { active: 'A', cancelled: 'C', guest: 'G' }
  enum email_preference: { all_emails: 2, important_emails: 1, no_emails: 0 }

  def apply_omniauth(omniauth)
    if omniauth['info'] && omniauth['info']['email']
      self.email = omniauth['info']['email']
    end
    authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  def cancel_account
    update_attributes(account_status: 'cancelled')
    # I had been destroying the authentications, but if I do this, if a Twitter/FB-only user comes back and wants to
    # re-enable their account, they can't because I destroyed the authentication. This fails because if they try to add
    # their auth back, they can't because their email exists in the database (albeit for a cancelled account) and can't be
    # used again.
    # self.authentications.destroy_all
  end

  def completed_orders
    orders.where("upper(status)='COMPLETED' or status='GIFT'")
  end

  def get_product_info_for_products_owned
    orders = completed_orders
    info_objects = []
    unless orders.empty?
      products = []
      orders.each do |order|
        order.line_items.each do |line_item|
          if products.include?(line_item.product_id)
            next
          else
            product = Product.find(line_item.product_id)
            products << product.id
            info_objects << get_info_for_product(product)
          end
        end
      end
    end
    Product.freebies.each do |product|
      info_objects << get_info_for_product(product)
    end
    info_objects
  end

  def get_info_for_product(product)
    product_info = Struct.new(:product, :download, :xml_list_ids, :html_list_ids, :image_url)
    image_url = product.main_image.thumb if product.main_image
    download = Download.find_by_user_id_and_product_id(id, product.id)
    if product.includes_instructions?
      html_list_ids = []
      xml_list_ids = []

      html_lists = PartsList.get_list(product.parts_lists, 'html')
      html_lists.each { |hl| html_list_ids << hl.id } if html_lists
      html_list_ids = nil if html_list_ids.blank?

      xml_lists = PartsList.get_list(product.parts_lists, 'xml')
      xml_lists.each { |xl| xml_list_ids << xl.id } if xml_lists
      xml_list_ids = nil if xml_list_ids.blank?
    else
      html_list_ids = nil
      xml_list_ids = nil
    end

    product_info.new(product, download, xml_list_ids, html_list_ids, image_url)
  end

  def owns_product?(product_id)
    li = line_items
    ownership = false
    li.each do |item|
      ownership = true if item.product_id == product_id.to_i
    end
    ownership
  end

  def guest?
    account_status == 'guest'
  end

  def set_up_guids
    self.guid = SecureRandom.hex(20)
    self.unsubscribe_token = SecureRandom.hex(20)
  end

  def self.who_get_all_emails
    User.where("email_preference = '2' and account_status <> 'C'").pluck(:email, :guid, :unsubscribe_token)
  end

  def self.who_get_important_emails
    User.where("email_preference in ('1','2') and account_status <> 'C'").pluck(:email, :guid, :unsubscribe_token)
  end
end
