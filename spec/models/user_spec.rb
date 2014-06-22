require 'spec_helper'

describe User do
  it "should not save if tos is not accepted" do
    @user = User.new(:email => 'test@test.com')

    @user.should_not be_valid
  end

  it "should not delete orders when user is deleted" do
    @user = FactoryGirl.create(:user)
    @order = FactoryGirl.create(:order)
    @user.destroy

    lambda { @user.destroy }.should_not change(Order, :count)
  end

  it "should not delete downloads when user is deleted" do
    @user = FactoryGirl.create(:user)
    @download = FactoryGirl.create(:download)
    @user.destroy

    lambda{@user.destroy}. should_not change(Download, :count)
  end

  it "should delete authentications when user is deleted" do
    @user = FactoryGirl.create(:user)
    authentication_hash = {'provider' => 'Twitter', 'uid' => '12345'}
    @user.apply_omniauth(authentication_hash)
    @user.save

    lambda{@user.destroy}.should change(Authentication, :count).from(1).to(0)
  end

  describe "apply_omniauth" do
    it "should apply omniauth, with a vengeance" do
      @user = FactoryGirl.create(:user)
      authentication_hash = {'provider' => 'Twitter', 'uid' => '12345'}
      @user.apply_omniauth(authentication_hash)

      lambda { @user.save }.should change(Authentication, :count).from(0).to(1)
    end
  end

  describe "password_required?" do
    it "should require a password of a user who has no authentications" do
      @user = FactoryGirl.create(:user)

      @user.password_required?.should == true
    end

    it "should not require a password of a user who has authentications" do
      @user = FactoryGirl.create(:user)
      authentication_hash = {'provider' => 'Twitter', 'uid' => '12345'}
      @user.apply_omniauth(authentication_hash)
      @user = User.last

      @user.password_required?.should == false
    end
  end

  describe "cancel_account" do
    it "should cancel account by changing account_status to 'C'" do
      @user = FactoryGirl.create(:user)

      lambda {@user.cancel_account}.should change(@user, :account_status).from("A").to("C")
    end

    it "should not delete a users authentications" do
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:authentication, :user_id => @user.id)
      FactoryGirl.create(:authentication, :provider => 'Facebook', :user_id => @user.id)
      @user = User.find(@user.id)

      lambda { @user.cancel_account }.should_not change(Authentication, :count)
    end
  end

  describe "completed_orders" do
    it "should return a list of completed orders" do
      @user = FactoryGirl.create(:user)
      @order1 = FactoryGirl.create(:order)
      @order2 = FactoryGirl.create(:order)
      @order3 = FactoryGirl.create(:order, :status => "INVALID")

      @user.completed_orders.should have(2).items
    end
  end

  describe "get_info_for_product" do
    it "should return a Struct with the product and info about the product, including parts list IDs" do
      @product_type = FactoryGirl.create(:product_type)
      @category = FactoryGirl.create(:category)
      @subcat = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @image = FactoryGirl.create(:image)
      @user = FactoryGirl.create(:user)
      @download = FactoryGirl.create(:download)
      @xml_list = FactoryGirl.create(:xml_parts_list)
      @html_list = FactoryGirl.create(:html_parts_list)
      product_info = @user.get_info_for_product(@product)

      expect(product_info.product).to be_a(Product)
      expect(product_info.download).to be_a(Download)
      expect(product_info.html_list_id).to eq(2)
      expect(product_info.xml_list_id).to eq(1)
      expect(product_info.image_url.to_s).to eq("/images/image/url/1/thumb_example.png")
    end

    it "should return a Struct with the product and info about the product, but nil parts list IDs" do
      @product_type1 = FactoryGirl.create(:product_type)
      @product_type2 = FactoryGirl.create(:product_type, name: 'Models')
      @category = FactoryGirl.create(:category)
      @subcat = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @product2 = FactoryGirl.create(:product, name: "Tower of Pisa Model", product_code: 'CB001M', product_type_id: @product_type2.id)
      @image = FactoryGirl.create(:image, product_id: @product2.id)
      @user = FactoryGirl.create(:user)
      @xml_list = FactoryGirl.create(:xml_parts_list)
      @html_list = FactoryGirl.create(:html_parts_list)
      product_info = @user.get_info_for_product(@product2)

      expect(product_info.product).to be_a(Product)
      expect(product_info.download).to be_nil
      expect(product_info.html_list_id).to be_nil
      expect(product_info.xml_list_id).to be_nil
      expect(product_info.image_url.to_s).to eq("/images/image/url/1/thumb_example.png")
    end
  end

  describe "get_product_info_for_products_owned" do
    it "should return an array of Structs with product info about the products the user has rights to" do
      @product_type = FactoryGirl.create(:product_type)
      @category = FactoryGirl.create(:category)
      @subcat = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @freebie = FactoryGirl.create(:free_product, product_code: 'FF001', name: 'Free stuff')
      @order = FactoryGirl.create(:order_with_line_items)
      @image = FactoryGirl.create(:image)
      @user = FactoryGirl.create(:user)
      @download = FactoryGirl.create(:download)
      @xml_list = FactoryGirl.create(:xml_parts_list)
      @html_list = FactoryGirl.create(:html_parts_list)
      product_info = @user.get_product_info_for_products_owned

      expect(product_info.length).to eq(2)
      expect(product_info[0].product).to be_a(Product)
      expect(product_info[0].download).to be_a(Download)
      expect(product_info[0].html_list_id).to eq(2)
      expect(product_info[0].xml_list_id).to eq(1)
      expect(product_info[0].image_url.to_s).to eq("/images/image/url/1/thumb_example.png")
      expect(product_info[1].product).to be_a(Product)
    end

    it "should not return a product a second time if a user has bought it twice" do
      @product_type = FactoryGirl.create(:product_type)
      @category = FactoryGirl.create(:category)
      @subcat = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @freebie = FactoryGirl.create(:free_product, product_code: 'FF001', name: 'Free stuff')
      @order = FactoryGirl.create(:order_with_line_items)
      @order2 = FactoryGirl.create(:order_with_line_items)
      @image = FactoryGirl.create(:image)
      @user = FactoryGirl.create(:user)
      @download = FactoryGirl.create(:download)
      @xml_list = FactoryGirl.create(:xml_parts_list)
      @html_list = FactoryGirl.create(:html_parts_list)
      product_info = @user.get_product_info_for_products_owned

      expect(product_info.length).to eq(2)
    end

    it "should return an empty array if a user does not have any completed orders" do
      @user = FactoryGirl.create(:user)

      expect(@user.get_product_info_for_products_owned).to eq([])
    end
  end
end
