require 'spec_helper'

describe Radmin do
  describe "is_valid_password?" do
    #This is basically setting up an alias for valid_password?
    it "should pass up the chain to valid_password? and return false for a bad password" do
      @radmin = FactoryGirl.create(:radmin, :password => "super_secret")
      @radmin.is_valid_password?("blar").should == false
    end

    it "should pass up the chain to valid_password? and return true for a good password" do
      @radmin = FactoryGirl.create(:radmin, :password => "super_secret")
      @radmin.is_valid_password?("super_secret").should == true
    end
  end
end
