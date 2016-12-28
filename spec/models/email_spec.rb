require 'spec_helper'

describe Email do
  describe 'persisted?' do
    it "should always return false" do
      email=Email.new
      expect(email.persisted?).to eq(false)
    end
  end
end