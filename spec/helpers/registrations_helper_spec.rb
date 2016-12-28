require 'spec_helper'

def current_user
  @user ||= FactoryGirl.create(:user)
end

describe RegistrationsHelper do
  describe "nice authentication list" do
    it "lists authentications in a nice format" do
      expect(helper.nice_authentications_list([FactoryGirl.create(:authentication)])).to eq("Twitter authentication")
    end
  end
end
