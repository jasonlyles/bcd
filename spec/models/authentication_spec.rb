require 'spec_helper'

describe Authentication do
  it "should be valid" do
    @user = FactoryBot.create(:user)
    @authentication = FactoryBot.create(:authentication, user: @user)

    expect(@authentication).to be_valid
  end

  it "should not be valid with invalid attributes" do
    expect(lambda{FactoryBot.create(:authentication, provider: nil)}).to raise_error(ActiveRecord::RecordInvalid)
  end
end
