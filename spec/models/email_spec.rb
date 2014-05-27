require 'spec_helper'

describe Email do
  describe 'persisted?' do
    it "should always return false" do
      email=Email.new
      email.persisted?.should eq(false)
    end
  end
end