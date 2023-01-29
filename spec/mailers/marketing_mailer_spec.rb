require 'spec_helper'

describe MarketingMailer do
  before do
    @product = FactoryBot.create(:product_with_associations)
    @user = FactoryBot.create(:user)
    @email_campaign = FactoryBot.create(:email_campaign)
  end

  describe 'sending a new product notification email to a user' do
    it 'should send user an email about the product' do
      @mail = MarketingMailer.new_product_notification(@product.attributes.to_json, @product.product_type.name, @product.main_image, @user.attributes.to_json, 'Test')
      expect(@mail.subject).to eq('New Product!')
      expect(@mail.to).to eq([@user.email])
      expect(@mail.from).to eq(['sales@brickcitydepot.com'])
    end
  end

  describe 'sending a new marketing email to a user' do
    it 'should send user a sweet marketing email' do
      @mail = MarketingMailer.new_marketing_notification(@email_campaign.attributes.to_json, @user.attributes.to_json)
      expect(@mail.subject).to eq('Sweet Email')
      expect(@mail.to).to eq([@user.email])
      expect(@mail.from).to eq(['sales@brickcitydepot.com'])
    end
  end
end
