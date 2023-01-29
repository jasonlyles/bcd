require 'spec_helper'

describe AdminController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
    @product_type = FactoryBot.create(:product_type)
    @category = FactoryBot.create(:category)
    @subcategory = FactoryBot.create(:subcategory)
    @product = FactoryBot.create(:product, category: @category, subcategory: @subcategory)
    @user = FactoryBot.create(:user)
  end

  describe 'gift_instructions' do
    it 'should create a new order with status = GIFT if could not find an order with status = GIFT' do
      sign_in @radmin

      expect { post :gift_instructions, format: :json, params: { gift: { 'user_id' => @user.id, 'product_id' => @product.id } } }.to change { Order.count }.by(1)
      expect(assigns(:order).status).to eq 'GIFT'
    end

    it 'should destroy the line_item for an order if the user owns the product via gifting' do
      order = FactoryBot.create(:order, status: 'GIFT')
      line_item = FactoryBot.create(:line_item, order_id: order.id, product_id: @product.id)
      sign_in @radmin

      expect { post :gift_instructions, format: :json, params: { gift: { 'user_id' => @user.id, 'product_id' => @product.id } } }.to change { LineItem.count }.by(-1)
    end

    it 'should add a line_item to the order if one does not already exist' do
      order = FactoryBot.create(:order, status: 'GIFT')
      sign_in @radmin

      expect { post :gift_instructions, format: :json, params: { gift: { 'user_id' => @user.id, 'product_id' => @product.id } } }.to change { LineItem.count }.by(1)
    end
  end

  describe 'update_order_shipping_status' do
    it 'should update the orders shipping status' do
      order = FactoryBot.create(:order, shipping_status: '0')
      sign_in @radmin
      put :update_order_shipping_status, params: { order_id: order.id, shipping_status: '1' }

      expect(assigns(:order).shipping_status).to eq(1)
      expect(response).to redirect_to('/order_fulfillment')
    end
  end

  describe 'order_fulfillment' do
    it 'should set up the order fulfillment page' do
      order1 = FactoryBot.create(:order, shipping_status: '0')
      order2 = FactoryBot.create(:order, shipping_status: '1')
      order3 = FactoryBot.create(:order, shipping_status: '1')
      sign_in @radmin

      get :order_fulfillment

      expect(assigns(:completed_orders).size).to eq(1)
      expect(assigns(:incomplete_orders).size).to eq(2)
    end
  end

  describe 'maintenance_mode' do
    it 'should render the maintenance mode page' do
      @switch = FactoryBot.create(:switch)
      sign_in @radmin
      get :maintenance_mode

      expect(response).to render_template('maintenance_mode')
      expect(assigns(:mm_switch).switch).to eq('maintenance_mode')
    end
  end

  describe 'switch_maintenance_mode' do
    it 'should switch maintenance mode on and off' do
      @switch = FactoryBot.create(:switch)
      sign_in @radmin
      post :switch_maintenance_mode

      expect(assigns(:mm_switch).switch_on).to eq(true)

      post :switch_maintenance_mode

      expect(assigns(:mm_switch).switch_on).to eq(false)
    end
  end

  describe 'admin_profile' do
    it "should return the admin's profile given the radmin's ID" do
      sign_in @radmin
      get 'admin_profile', params: { id: @radmin.id }
      expect(assigns(:radmin).id).to eq(@radmin.id)
    end
  end

  describe 'update_admin_profile' do
    it "given valid params, should update the admin's profile" do
      sign_in @radmin
      put :update_admin_profile, params: { id: @radmin.id, radmin: { email: 'silly@billy.com' } }
      @radmin = Radmin.find(@radmin.id)

      expect(assigns(:radmin).errors.messages).to eq({})
      expect(flash[:notice]).to eq('Profile was successfully updated.')
      expect(@radmin.email).to eq('silly@billy.com')
    end

    it "with an invalid password, should not update the admin's profile" do
      sign_in @radmin
      put :update_admin_profile, params: { id: @radmin.id, radmin: { current_password: 'blar' } }

      expect(assigns(:radmin).errors.messages).to eq({ current_password: ['is invalid.'] })
    end

    it "with an invalid email address, should not update the admin's profile" do
      sign_in @radmin
      put :update_admin_profile, params: { id: @radmin.id, radmin: { email: '6' } }

      expect(assigns(:radmin).errors.messages).to eq({ email: ['is invalid'] })
    end
  end

  describe 'updates_users_download_count' do
    it 'should set up products in a useful way' do
      sign_in @radmin
      get :update_users_download_counts

      expect(assigns(:products)).to eq([["#{@product.product_code} #{@product.name}", @product.id]])
    end
  end

  describe 'update_downloads_for_users' do
    it 'should flash a happy message if jobs are enqueued' do
      sign_in @radmin
      expect(ProductUpdateNotificationJob).to receive(:perform_async)
      get :update_downloads_for_users, params: { user: { model: 1 } }

      expect(flash[:notice]).to eq('Sending product update emails')
    end
  end

  describe 'send_new_product_notification' do
    it 'should flash a happy message if jobs are enqueued' do
      sign_in @radmin
      expect(NewProductNotificationJob).to receive(:perform_async)
      post :send_new_product_notification, params: { email: { 'product_id' => 1, 'optional_message' => 'Hi!' } }

      expect(flash[:notice]).to eq('Sending new product emails')
    end
  end
end
