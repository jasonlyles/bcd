require 'spec_helper'

describe UpdateMailer do
  before do
    @product_type = FactoryBot.create(:product_type)
    @category = FactoryBot.create(:category)
    @subcategory = FactoryBot.create(:subcategory, category_id: @category.id)
    @user = FactoryBot.create(:user)
    @model = FactoryBot.create(:product, subcategory_id: @subcategory.id, category_id: @category.id)
  end

  describe 'sending email for updated instructions' do
    it 'should send user an email for instructions that have been updated' do
      mail = UpdateMailer.updated_instructions(@user.id, @model.id, message = 'BLAH BLAH BLAH')

      expect(mail.subject).to eq('Instructions for CB001 Colonial Revival House have been updated')
      expect(mail.to).to eq([@user.email])
      expect(mail.from).to eq(['sales@brickcitydepot.com'])
      mail.body.parts.each do |part|
        expect(part.body).to match('BLAH BLAH BLAH')
      end
    end
  end

  describe 'updated_parts_lists' do
    it 'should send a user an email about a parts list that has been updated' do
      mail = UpdateMailer.updated_parts_lists(@user.id, ['Thing 1', 'Thing 2'], message = 'Updated parts lists for both Things')

      expect(mail.subject).to eq('Parts lists for instructions you own have been updated')
      expect(mail.to).to eq([@user.email])
      expect(mail.from).to eq(['sales@brickcitydepot.com'])
      mail.body.parts.each do |part|
        expect(part.body).to match('Thing 1')
        expect(part.body).to match('Thing 2')
        expect(part.body).to match('Updated parts lists for both Things')
      end
    end
  end
end

# def updated_parts_lists(user_id, product_names, message)
#   @host = Rails.application.config.web_host
#   @user = User.find(user_id)
#   @products = product_names
#   @message = message
#   @hide_unsubscribe = true
#
#   mail(to: @user.email, subject: 'Parts lists for instructions you own have been updated')
# end
