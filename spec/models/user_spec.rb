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
end
