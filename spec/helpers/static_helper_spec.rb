require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the StaticHelper. For example:
#
# describe StaticHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
#def current_user
#  @user ||= FactoryGirl.create(:user)
#end

describe StaticHelper do
  describe "remaining downloads" do
    it "tells how many downloads a user has left" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      expect(helper.downloads_remaining(1)).to eq(5)
    end
  end
end
