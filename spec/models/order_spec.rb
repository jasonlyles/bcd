require 'spec_helper'

describe Order do
  before do
    @product = FactoryBot.create(:product_with_associations)
  end

  describe 'has_physical_product?' do
    it "should return false if the order doesn't include a physical product" do
      li1 = LineItem.new product_id: @product.id, quantity: 1, total_price: 5
      order = Order.new
      order.line_items << li1
      expect(order.includes_physical_item?).to eq(false)
    end

    it 'should return true if the order includes a physical product' do
      product_type = FactoryBot.create(:product_type, name: 'Models', digital_product: false)
      product2 = FactoryBot.create(:physical_product, product_type_id: product_type.id)
      li1 = LineItem.create product_id: product2.id, quantity: 1, total_price: 5
      order = Order.create
      order.line_items << li1

      expect(order.includes_physical_item?).to eq(true)
    end
  end

  describe 'includes_digital_item?' do
    it 'should return true if the order has at least one digital product' do
      li1 = LineItem.new product_id: @product.id, quantity: 1, total_price: 5
      order = Order.new
      order.line_items << li1
      expect(order.includes_digital_item?).to eq(true)
    end

    it "should return false if the order doesn't have at least one digital product" do
      product_type = FactoryBot.create(:product_type, name: 'Models', digital_product: false)
      product = FactoryBot.create(:physical_product, product_type_id: product_type.id)
      li1 = LineItem.new product_id: product.id, quantity: 1, total_price: 5
      order = Order.new
      order.line_items << li1

      expect(order.includes_digital_item?).to eq(false)
    end
  end

  describe 'retrieve_digital_items' do
    it 'should return an array of digital products if the order includes digital products' do
      FactoryBot.create(:product_type, name: 'Models', digital_product: false)
      product2 = FactoryBot.create(:product, name: 'fake', product_code: 'CB099', price: 10)
      product3 = FactoryBot.create(:physical_product)
      li1 = LineItem.new product_id: @product.id, quantity: 1, total_price: 5
      li2 = LineItem.new product_id: product2.id, quantity: 1, total_price: 10
      li3 = LineItem.new product_id: product3.id, quantity: 1, total_price: 25
      order = Order.new
      order.line_items << li1
      order.line_items << li2
      order.line_items << li3

      expect(order.retrieve_digital_items.length).to eq 2
    end

    it "should return an empty array if the order doesn't include digital products" do
      product_type = FactoryBot.create(:product_type, name: 'Models', digital_product: false)
      product = FactoryBot.create(:physical_product, product_type:)
      li1 = LineItem.new product: product, quantity: 1, total_price: 5
      order = Order.new
      order.line_items << li1

      expect(order.retrieve_digital_items).to eq []
    end
  end

  describe 'self.shipping_status_not_complete' do
    it 'should get records where shipping status is not complete' do
      order1 = FactoryBot.create(:order, { shipping_status: '1' })
      order2 = FactoryBot.create(:order, { shipping_status: '0' })
      order3 = FactoryBot.create(:order, { shipping_status: '1' })

      orders = Order.shipping_status_not_complete
      expect(orders.length).to eq(2)
    end
  end

  describe 'self.shipping_status_complete' do
    it 'should get records where shipping status is complete' do
      order1 = FactoryBot.create(:order, { shipping_status: '1' })
      order2 = FactoryBot.create(:order, { shipping_status: '0' })
      order3 = FactoryBot.create(:order, { shipping_status: '0' })

      orders = Order.shipping_status_complete
      expect(orders.length).to eq(2)
    end
  end

  describe 'add_line_items_from_cart' do
    it 'should add line items from cart' do
      cart = Cart.new
      cart.add_product(@product)
      cart.add_product(FactoryBot.create(:product,
                                         name: 'Grader',
                                         product_code: 'WC002',
                                         description: 'Winter Village Grader... are you kidding? w00t! Plow your winter village to the ground and then flatten it out with this sweet grader.',
                                         price: '5.00',
                                         ready_for_public: 't'))

      order = Order.new
      order.add_line_items_from_cart(cart)

      expect(order.line_items.size).to eq(2)
    end
  end

  describe 'total_price' do
    it 'should return a total price' do
      li1 = LineItem.new product_id: 1, quantity: 1, total_price: 5
      li2 = LineItem.new product_id: 2, quantity: 1, total_price: 10
      order = Order.new
      order.line_items << li1
      order.line_items << li2
      expect(order.total_price).to eq(15.0)
    end
  end

  it 'should delete related line_items when it gets deleted' do
    @order = FactoryBot.create(:order_with_line_items)

    expect { @order.destroy }.to change(LineItem, :count).from(1).to(0)
  end

  describe 'Order.all_transactions_for_month' do
    it 'should return an array o arrays with each array representing a single transaction, with all transactions for a month' do
      @user = FactoryBot.create(:user)
      @order = FactoryBot.create(:order_with_line_items, created_at: Date.today, user_id: @user.id)
      transactions = Order.all_transactions_for_month(Date.today.month, Date.today.year)
      expect(transactions).to eq([['charlie_brown@peanuts.com', 'blarney', 'blar', 'COMPLETED', Date.today.strftime('%m/%d/%Y'), 'CB001 Colonial Revival House', 1, '10.0']])
    end
  end

  describe 'Order.transaction_csv' do
    it 'should take transactions fed in and return a csv' do
      @user = FactoryBot.create(:user)
      @order = FactoryBot.create(:order_with_line_items, created_at: Date.today, user_id: @user.id)
      transactions = Order.all_transactions_for_month(Date.today.month, Date.today.year)
      transaction_csv = Order.transaction_csv(transactions)
      expect(transaction_csv).to eq("Email,Transaction ID,Request ID,Status,Date,Product,Qty,Total Price\ncharlie_brown@peanuts.com,blarney,blar,COMPLETED,#{Date.today.strftime('%m/%d/%Y')},CB001 Colonial Revival House,1,10.0\n")
    end
  end

  describe 'retrieve_download_links' do
    context 'the product in question includes instructions' do
      it 'should return an array of urls with query strings, paired with descriptive titles for each link, and the remaining download count' do
        user = FactoryBot.create(:user)
        order = FactoryBot.create(:order_with_line_items, created_at: Date.today, user:)
        expect(SecureRandom).to receive(:hex).and_return('fake_hex')

        links = order.retrieve_download_links
        expect(links).to eq([[['CB001 Colonial Revival House PDF', "/guest_download?id=#{user.guid}&token=fake_hex", 5]], []])
      end
    end

    context 'the product in question does not include instructions' do
      it 'should return an empty array' do
        product_type = FactoryBot.create(:product_type, name: 'Crafts', digital_product: false)
        user = FactoryBot.create(:user)
        product = FactoryBot.create(:product, product_type:, name: 'Crafty', product_code: 'CR001')
        li = LineItem.new product: product, quantity: 1, total_price: 10
        order = FactoryBot.create(:order, created_at: Date.today, user:)
        order.line_items << li

        links = order.retrieve_download_links
        expect(links).to eq([[], []])
      end
    end
  end

  describe 'retrieve_link_to_downloads' do
    context 'there is no transaction ID in the order record' do
      it 'should return a link to the download_error_page' do
        user = FactoryBot.create(:user)
        order = FactoryBot.create(:order_with_line_items, created_at: Date.today, user:)
        order.transaction_id = nil
        link = order.retrieve_link_to_downloads

        expect(link).to eq('http://localhost:3000/download_link_error')
      end
    end

    context 'there is no request ID in the order record' do
      it 'should return a link to the download_error_page' do
        user = FactoryBot.create(:user)
        order = FactoryBot.create(:order_with_line_items, created_at: Date.today, user:)
        order.request_id = nil
        link = order.retrieve_link_to_downloads

        expect(link).to eq('http://localhost:3000/download_link_error')
      end
    end

    context 'there is a transaction ID and request ID in the order record' do
      it 'should return a link to guest_downloads with a query string' do
        user = FactoryBot.create(:user)
        order = FactoryBot.create(:order_with_line_items, created_at: Date.today, user:)
        link = order.retrieve_link_to_downloads

        expect(link).to eq('http://localhost:3000/guest_downloads?tx_id=blarney&conf_id=blar')
      end
    end

    context 'with a third party receipt present' do
      it 'should return a link to guest_downloads for third party users' do
        user = FactoryBot.create(:user)
        order = FactoryBot.create(:order_with_line_items, created_at: Date.today, user:)
        third_party_receipt = FactoryBot.create(:third_party_receipt, order:)
        link = order.retrieve_link_to_downloads

        expect(link).to eq("http://localhost:3000/guest_downloads?source=etsy&order_id=abcd1234&u=#{user.guid}")
      end
    end
  end

  describe 'third_party_order_incomplete_for_more_than_a_day?' do
    it 'should return third party orders incomplete for more than a day' do
      order1 = FactoryBot.create(:order, status: 'THIRD_PARTY_PENDING_PAYMENT', updated_at: Time.now - 2.days)
      order2 = FactoryBot.create(:order, status: 'THIRD_PARTY_PENDING', updated_at: Time.now - 25.hours)
      order3 = FactoryBot.create(:order, status: 'THIRD_PARTY_PENDING', updated_at: Time.now - 23.hours)
      order4 = FactoryBot.create(:order, status: 'THIRD_PARTY_CANCELED', updated_at: Time.now - 25.hours)

      expect(order1.third_party_order_incomplete_for_more_than_a_day?).to eq(true)
      expect(order2.third_party_order_incomplete_for_more_than_a_day?).to eq(true)
      expect(order3.third_party_order_incomplete_for_more_than_a_day?).to eq(false)
      expect(order4.third_party_order_incomplete_for_more_than_a_day?).to eq(false)
    end
  end
end
