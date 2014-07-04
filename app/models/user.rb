class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable, :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :email_preference, :account_status, :tos_accepted, :referrer_code

  has_many :orders
  has_many :line_items, :through => :orders
  has_many :authentications, :dependent => :destroy
  has_many :downloads
  has_one :cart

  validates :tos_accepted, :acceptance => {:accept => true}

  before_create :set_up_guids

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
    orders.where("status='COMPLETED'")
  end

  def get_product_info_for_products_owned
    orders = completed_orders
    if orders.length > 0
      products,info_objects = [],[]
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
      Product.freebies.each do |product|
        info_objects << get_info_for_product(product)
      end
    else
      return []
    end
    info_objects
  end

  def get_info_for_product(product)
    product_info = Struct.new(:product, :download, :xml_list_id, :html_list_id, :image_url)
    image_url = product.main_image.thumb if product.main_image
    download = Download.find_by_user_id_and_product_id(self.id,product.id)
    if product.includes_instructions?
      html_list = PartsList.get_list(product.parts_lists, 'html')
      html_list_id = html_list.id if html_list
      xml_list = PartsList.get_list(product.parts_lists, 'xml')
      xml_list_id = xml_list.id if xml_list
    else
      html_list_id,xml_list_id = nil, nil
    end

    product_info.new(product, download, xml_list_id, html_list_id, image_url)
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
end
