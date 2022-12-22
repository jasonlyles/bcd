require 'spec_helper'

describe User do
  before do
    @product = FactoryGirl.create(:product_with_associations)
  end

  describe 'owns_product?' do
    it 'should include freebies as a product that the user owns' do
      # No connecting line_item from an order here, just a free product that any
      # user who signs up can access.
      user = FactoryGirl.create(:user)
      product = FactoryGirl.create(:free_product, name: 'Live Free Or Die', product_code: 'FR001')

      expect(user.owns_product?(product.id)).to eq(true)
    end
  end

  it "should not save if tos is not accepted" do
    user = User.new(email: 'test@test.com')

    expect(user).to_not be_valid
  end

  it "should not delete orders when user is deleted" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:order, user: user)

    expect(lambda { user.destroy }).to_not change(Order, :count)
  end

  it "should not delete downloads when user is deleted" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:download, user: user)

    expect(lambda{ user.destroy }).to_not change(Download, :count)
  end

  it "should delete authentications when user is deleted" do
    user = FactoryGirl.create(:user)
    authentication_hash = { 'provider' => 'Twitter', 'uid' => '12345' }
    user.apply_omniauth(authentication_hash)
    user.save

    expect(lambda{ user.destroy }).to change(Authentication, :count).from(1).to(0)
  end

  describe "apply_omniauth" do
    it "should apply omniauth, with a vengeance" do
      user = FactoryGirl.create(:user)
      authentication_hash = { 'provider' => 'Twitter', 'uid' => '12345' }
      user.apply_omniauth(authentication_hash)

      expect(lambda { user.save }).to change(Authentication, :count).from(0).to(1)
    end
  end

  describe "password_required?" do
    it "should require a password of a user who has no authentications" do
      user = FactoryGirl.create(:user)

      expect(user.password_required?).to eq(true)
    end

    it "should not require a password of a user who has authentications" do
      user = FactoryGirl.create(:user)
      authentication_hash = { 'provider' => 'Twitter', 'uid' => '12345' }
      user.apply_omniauth(authentication_hash)
      user = User.last

      expect(user.password_required?).to eq(false)
    end
  end

  describe "cancel_account" do
    it "should cancel account by changing account_status to 'C'" do
      user = FactoryGirl.create(:user)

      expect(lambda { user.cancel_account }).to change(user, :account_status).from('A').to('C')
    end

    it "should not delete a users authentications" do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:authentication, user: user)
      FactoryGirl.create(:authentication, provider: 'Facebook', user: user)
      user = User.find(user.id)

      expect(lambda { user.cancel_account }).to_not change(Authentication, :count)
    end
  end

  describe "completed_orders" do
    it "should return a list of completed orders" do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:order)
      FactoryGirl.create(:order)
      FactoryGirl.create(:order, status: 'INVALID')

      expect(user.completed_orders.size).to eq(2)
    end
  end

  describe "get_info_for_product" do
    it "should return a Struct with the product and info about the product, including parts list IDs" do
      FactoryGirl.create(:image)
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:download)
      product_info = user.get_info_for_product(@product)

      expect(product_info.product).to be_a(Product)
      expect(product_info.download).to be_a(Download)
      expect(product_info.image_url.to_s).to eq("/images/image/url/1/thumb_example.png")
    end

    it "should return a Struct with the product and info about the product, but nil parts list IDs" do
      product_type2 = FactoryGirl.create(:product_type, name: 'Models')
      product2 = FactoryGirl.create(:product, name: 'Tower of Pisa Model', product_code: 'CB001M', product_type: product_type2)
      image = FactoryGirl.create(:image, product_id: product2.id)
      user = FactoryGirl.create(:user)
      product_info = user.get_info_for_product(product2)

      expect(product_info.product).to be_a(Product)
      expect(product_info.download).to be_nil
      expect(product_info.image_url.to_s).to eq("/images/image/url/1/thumb_example.png")
    end
  end

  describe "product_info_for_products_owned" do
    it "should return an array of Structs with product info about the products the user has rights to" do
      FactoryGirl.create(:free_product, product_code: 'FF001', name: 'Free stuff')
      FactoryGirl.create(:order_with_line_items)
      FactoryGirl.create(:image)
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:download)
      product_info = user.product_info_for_products_owned

      expect(product_info.length).to eq(2)
      expect(product_info[0].product).to be_a(Product)
      expect(product_info[0].download).to be_a(Download)
      expect(product_info[0].image_url.to_s).to eq("/images/image/url/1/thumb_example.png")
      expect(product_info[1].product).to be_a(Product)
    end

    it "should not return a product a second time if a user has bought it twice" do
      FactoryGirl.create(:free_product, product_code: 'FF001', name: 'Free stuff')
      FactoryGirl.create(:order_with_line_items)
      FactoryGirl.create(:order_with_line_items)
      FactoryGirl.create(:image)
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:download)
      product_info = user.product_info_for_products_owned

      expect(product_info.length).to eq(2)
    end

    it "should return an empty array if a user does not have any completed orders" do
      user = FactoryGirl.create(:user)

      expect(user.product_info_for_products_owned).to eq([])
    end
  end

  describe "self.who_get_all_emails" do
    it 'should return email, guid and unsubscribe_token for users with email_preference of 2 and who are not cancelled' do
      user1 = FactoryGirl.create(:user, email_preference: 1, account_status: 'A')
      user2 = FactoryGirl.create(:user, email: 'user2@gmail.com', email_preference: 2, account_status: 'C')
      user3 = FactoryGirl.create(:user, email: 'user3@gmail.com', email_preference: 2, account_status: 'A')
      user4 = FactoryGirl.create(:user, email: 'user4@gmail.com', email_preference: 2, account_status: 'A')

      expect(User.who_get_all_emails).to eq([[user3.email, user3.guid, user3.unsubscribe_token], [user4.email, user4.guid, user4.unsubscribe_token]])
    end
  end

  describe "self.who_get_important_emails" do
    it 'should return email, guid and unsubscribe_token for users with email_preference of 1 or 2 and who are not cancelled' do
      user1 = FactoryGirl.create(:user, email_preference: 1, account_status: 'A')
      user2 = FactoryGirl.create(:user, email: 'user2@gmail.com', email_preference: 2, account_status: 'C')
      user3 = FactoryGirl.create(:user, email: 'user3@gmail.com', email_preference: 0, account_status: 'A')
      user4 = FactoryGirl.create(:user, email: 'user4@gmail.com', email_preference: 2, account_status: 'A')

      expect(User.who_get_important_emails).to eq([[user1.email, user1.guid, user1.unsubscribe_token], [user4.email, user4.guid, user4.unsubscribe_token]])
    end
  end
end
