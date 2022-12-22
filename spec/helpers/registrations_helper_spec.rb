require 'spec_helper'

describe RegistrationsHelper do
  describe "nice authentication list" do
    it "lists authentications in a nice format" do
      FactoryGirl.create(:user)
      expect(helper.nice_authentications_list([FactoryGirl.create(:authentication)])).to eq("Twitter authentication")
    end
  end
end
