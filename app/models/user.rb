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

  validates :tos_accepted, :acceptance => {:accept => true}# => {:message => "must be accepted."}

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
    self.orders.where("status='COMPLETED'")
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
end
