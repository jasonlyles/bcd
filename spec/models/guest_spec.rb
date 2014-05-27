require 'spec_helper'

describe Guest do
  describe 'apply_omniauth' do
    it 'should always return nil' do
      guest = Guest.new
      guest.apply_omniauth.should be_nil
    end
  end

  describe 'password_required?' do
    it 'should always return false' do
      guest = Guest.new
      guest.password_required?.should eq(false)
    end
  end

  describe 'cancel_account' do
    it 'should always return nil' do
      guest=Guest.new
      guest.cancel_account.should be_nil
    end
  end
end