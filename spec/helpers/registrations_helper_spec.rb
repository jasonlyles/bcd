require 'spec_helper'

describe RegistrationsHelper do
  describe 'nice authentication list' do
    it 'lists authentications in a nice format' do
      FactoryBot.create(:user)

      expect(helper.nice_authentications_list([FactoryBot.create(:authentication)])).to eq('Twitter authentication')
    end
  end

  describe 'all_auths_taken' do
    it 'lets me know if the user has already used all auths available' do
      FactoryBot.create(:user)

      expect(helper.all_auths_taken([FactoryBot.create(:authentication, provider: 'Twitter'), FactoryBot.create(:authentication, provider: 'Facebook')])).to eq(true)
      expect(helper.all_auths_taken([FactoryBot.create(:authentication, provider: 'Twitter')])).to eq(false)
    end
  end
end
