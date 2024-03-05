require 'spec_helper'

describe OrderMailer do
  before do
    @product_type1 = FactoryBot.create(:product_type)
    @product_type2 = FactoryBot.create(:product_type, name: 'Models', digital_product: false)
    @category = FactoryBot.create(:category)
    @subcategory = FactoryBot.create(:subcategory)
    FactoryBot.create(:product, product_type_id: @product_type1.id, category_id: @category.id, subcategory_id: @subcategory.id, product_code: 'XX111', name: 'fake product')
    @product = FactoryBot.create(:product, product_type_id: @product_type2.id, category_id: @category.id, subcategory_id: @subcategory.id, product_code: 'XX111M')
    @user = FactoryBot.create(:user)
    @order = FactoryBot.create(:order)
    @line_item = FactoryBot.create(:line_item, product_id: @product.id, order_id: @order.id)
    @mail = OrderMailer.order_confirmation(@user.id, @order.id)
    @physical_mail = OrderMailer.physical_item_purchased(@user.id, @order.id)
    @third_party_order = FactoryBot.create(:order, source: 'etsy', third_party_order_identifier: 'abcd1234')
    @third_party_receipt = FactoryBot.create(:third_party_receipt, order: @third_party_order)
  end

  describe 'sending an order confirmation email to a user' do
    it 'should send user an email for the order they placed' do
      expect(@mail.subject).to eq('Brick City Depot Order Confirmation')
      expect(@mail.to).to eq([@user.email])
      expect(@mail.from).to eq(['sales@brickcitydepot.com'])
      @mail.body.parts.each do |part|
        expect(part.body).to match('Thank you for placing an order')
        expect(part.body).to match('charlie_brown@peanuts.com')
      end
    end
  end

  describe 'sending an order confirmation email to a guest' do
    it 'should send guest an email for the order they placed' do
      link = '/guest_download?id=blar'
      @guest_mail = OrderMailer.guest_order_confirmation(@user.id, @order.id, link)

      expect(@guest_mail.subject).to eq('Your Brick City Depot Order')
      expect(@guest_mail.to).to eq([@user.email])
      expect(@guest_mail.from).to eq(['sales@brickcitydepot.com'])
      @guest_mail.body.parts.each do |part|
        expect(part.body).to match('Thank you for placing an order')
        expect(part.body).to match('charlie_brown@peanuts.com')
        expect(part.body).to match('To access instructions')
        expect(part.body).to match('guest_download\?id=blar')
      end
    end
  end

  describe 'notifying admins for a physical item purchased' do
    it 'should send admin an email if a physical item is purchased' do
      expect(@physical_mail.subject).to eq('Physical Item Purchased')
      expect(@physical_mail.to).to eq(['lylesjt@gmail.com'])
      expect(@physical_mail.from).to eq(['sales@brickcitydepot.com'])
      @physical_mail.body.parts.each do |part|
        expect(part.body).to match('charlie_brown@peanuts.com')
        expect(part.body).to match(@product.name)
        expect(part.body).to match('Just wanted to let you know you sold a physical item and need to be thinking about boxing up that junk and shipping it out!')
      end
    end
  end

  describe 'follow_up' do
    it 'should email recommended products to a user who has recently purchased' do
      FactoryBot.create(:product, product_type_id: @product_type1.id, category_id: @category.id, subcategory_id: @subcategory.id, product_code: 'CB002', name: 'Something')
      mail = OrderMailer.follow_up(@order.id)

      expect(mail.subject).to eq('Thanks for your recent order')
      expect(mail.from).to eq(['sales@brickcitydepot.com'])
      expect(mail.to).to eq(['charlie_brown@peanuts.com'])

      mail.body.parts.each do |part|
        expect(part.body).to match('Thank you for your recent order')
        expect(part.body).to match('XX111/fake_product')
        expect(part.body).to match('CB002/something')
      end
    end
  end

  describe 'issue' do
    it 'should email a reported issue about an order to admins' do
      mail = OrderMailer.issue(@order.id, 'I have an issue', 'Bob')

      expect(mail.subject).to eq('Issue with Brick City Depot Order #blar')
      expect(mail.from).to eq(['sales@brickcitydepot.com'])
      expect(mail.to).to eq(['charlie_brown@peanuts.com', 'sales@brickcitydepot.com'])

      expect(mail.body).to match('I had an issue with this order')
      expect(mail.body).to match('I have an issue')
      expect(mail.body).to match('Bob')
    end
  end

  describe 'third_party_guest_order_confirmation' do
    it 'should send guest an email for the order they placed' do
      @guest_mail = OrderMailer.third_party_guest_order_confirmation(@third_party_order.id)

      expect(@guest_mail.subject).to eq('Your Etsy Order with Brick City Depot')
      expect(@guest_mail.to).to eq([@user.email])
      expect(@guest_mail.from).to eq(['sales@brickcitydepot.com'])
      @guest_mail.body.parts.each do |part|
        expect(part.body).to match('Thank you for placing an order')
        expect(part.body).to match('charlie_brown@peanuts.com')
        expect(part.body).to match('still access the instructions')
        if part.content_type.match(/text\/plain/)
          expect(part.body).to match("guest_downloads\\?source=etsy&order_id=#{@third_party_order.third_party_order_identifier}&u=#{@user.guid}")
        else
          expect(part.body).to match("guest_downloads\\?source=etsy&amp;order_id=#{@third_party_order.third_party_order_identifier}&amp;u=#{@user.guid}")
        end
      end
    end
  end

  describe 'pass_along_buyer_message' do
    it 'should send an email to admins about a message the 3rd party buyer sent' do
      source = 'etsy'
      @mail = OrderMailer.pass_along_buyer_message(source, @third_party_order.id, 'ralph@worlddom.mil', 'Just a message')

      expect(@mail.subject).to eq("Brick City Depot message from #{source.capitalize} buyer")
      expect(@mail.from).to eq(['sales@brickcitydepot.com'])
      expect(@mail.to).to eq(['lylesjt@gmail.com'])

      expect(@mail.body).to match('Just a message')
      expect(@mail.body).to match('ralph@worlddom.mil')
      expect(@mail.body).to match(source.capitalize)
      expect(@mail.body).to match("\/admin\/orders\/#{@third_party_order.id}")
    end
  end
end
