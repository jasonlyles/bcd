require 'spec_helper'

describe Guest do
  describe 'apply_omniauth' do
    it 'should always return nil' do
      guest = Guest.new
      expect(guest.apply_omniauth).to be_nil
    end
  end

  describe 'password_required?' do
    it 'should always return false' do
      guest = Guest.new
      expect(guest.password_required?).to eq(false)
    end
  end

  describe 'cancel_account' do
    it 'should always return nil' do
      guest=Guest.new
      expect(guest.cancel_account).to be_nil
    end
  end
end