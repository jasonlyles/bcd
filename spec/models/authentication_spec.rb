require 'spec_helper'

describe Authentication do
  it "should be valid" do
    @authentication = FactoryGirl.create(:authentication)

    @authentication.should be_valid
  end

  it "should not be valid with invalid attributes" do
    lambda{FactoryGirl.create(:authentication, :provider => nil)}.should raise_error(ActiveRecord::RecordInvalid)
  end
end
