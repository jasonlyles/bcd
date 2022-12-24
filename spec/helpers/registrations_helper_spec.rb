require 'spec_helper'

describe RegistrationsHelper do
  describe "nice authentication list" do
    it "lists authentications in a nice format" do
      FactoryBot.create(:user)
      expect(helper.nice_authentications_list([FactoryBot.create(:authentication)])).to eq("Twitter authentication")
    end
  end
end
