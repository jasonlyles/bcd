require 'spec_helper'

describe Admin::OrdersController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
  end

  before(:each) do
    sign_in @radmin
  end

  describe 'GET #index' do
    it 'assigns all orders as @orders' do
      order = FactoryBot.create(:order)
      get :index

      expect(assigns(:orders)).to eq([order])
    end
  end

  describe 'GET #show' do
    it 'should return an order given the orders ID' do
      order = FactoryBot.create(:order)
      sign_in @radmin
      get :show, params: { id: order.id }

      expect(assigns(:order).id).to eq(order.id)
    end
  end

  describe 'complete_order' do
    it 'should set the orders status to COMPLETED and redirect back' do
      order = FactoryBot.create(:order, status: 'incomplete')
      request.env['HTTP_REFERER'] = '/'
      sign_in @radmin
      post :complete_order, params: { id: order.id }

      expect(assigns(:order).status).to eq('COMPLETED')
      expect(response).to redirect_to('/')
    end
  end
end
