class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :email_preference, :account_status, :tos_accepted, :referrer_code

  has_many :orders
  has_many :line_items, :through => :orders
  has_many :products, :through => :line_items
  has_many :authentications, :dependent => :destroy
  has_many :downloads
  has_one :cart
  has_many :user_parts_lists
  has_many :parts_lists, through: :user_parts_lists

  validates :tos_accepted, :acceptance => {:accept => true}

  before_create :set_up_guids
  before_save do
    self.email.downcase!
  end

  def apply_omniauth(omniauth)
    if omniauth['info'] && omniauth['info']['email']
      self.email = omniauth['info']['email']
    end
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  def cancel_account
    self.update_attributes(:account_status => "C")
    #I had been destroying the authentications, but if I do this, if a Twitter/FB-only user comes back and wants to
    #re-enable their account, they can't because I destroyed the authentication. This fails because if they try to add
    #their auth back, they can't because their email exists in the database (albeit for a cancelled account) and can't be
    #used again.
    #self.authentications.destroy_all
  end

  def completed_orders
    orders.where("upper(status)='COMPLETED' or status='GIFT'")
  end

  def get_product_info_for_products_owned
    orders = completed_orders
    info_objects = []
    if orders.length > 0
      products = []
      orders.includes(:line_items).each do |order|
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
    product_info = Struct.new(:product, :download, :image_url, :parts_list_ids)
    image_url = product.main_image.thumb if product.main_image
    download = Download.find_by_user_id_and_product_id(self.id,product.id)

    if product.includes_instructions?
      parts_list_ids = product.parts_lists.map(&:id)
    else
      parts_list_ids = nil
    end

    product_info.new(product, download, image_url, parts_list_ids)
  end

  def owns_product?(product_id)
    li = self.line_items
    ownership = false
    li.each do |item|
      if item.product_id == product_id.to_i
        ownership = true
      end
    end
    ownership
  end

  def guest?
    account_status == 'G'
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

  def has_access_to_parts_list?(parts_list_id)
    product_id = PartsList.find(parts_list_id)&.product_id
    product_id.blank? ? false : owns_product?(product_id)
  end
end
