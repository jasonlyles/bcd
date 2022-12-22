require 'spec_helper'

describe Authentication do
  it "should be valid" do
    @user = FactoryGirl.create(:user)
    @authentication = FactoryGirl.create(:authentication, user: @user)

    expect(@authentication).to be_valid
  end

  it "should not be valid with invalid attributes" do
    expect(lambda{FactoryGirl.create(:authentication, provider: nil)}).to raise_error(ActiveRecord::RecordInvalid)
  end
end
