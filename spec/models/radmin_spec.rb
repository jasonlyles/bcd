require 'spec_helper'

describe Radmin do
  describe "valid_password?" do
    #This is basically setting up an alias for valid_password?
    it "should pass up the chain to valid_password? and return false for a bad password" do
      @radmin = FactoryBot.create(:radmin, :password => "super_secret")
      expect(@radmin.valid_password?("blar")).to eq(false)
    end

    it "should pass up the chain to valid_password? and return true for a good password" do
      @radmin = FactoryBot.create(:radmin, :password => "super_secret")
      expect(@radmin.valid_password?("super_secret")).to eq(true)
    end
  end
end
