# frozen_string_literal: true

require 'spec_helper'

describe Admin::BackendNotificationsController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
    @partner = FactoryBot.create(:partner, id: 1)
  end

  before(:each) do
    sign_in @radmin
  end

  describe 'GET #index' do
    it 'assigns all backend_notifications as @backend_notifications' do
      backend_notification = FactoryBot.create(:backend_notification)
      get :index

      expect(assigns(:backend_notifications)).to eq([backend_notification])
    end
  end

  describe 'PUT #dismiss' do
    it 'should update the notifications dismissed_by_id' do
      backend_notification = FactoryBot.create(:backend_notification)
      put :dismiss, params: { id: backend_notification.id }, format: :js

      backend_notification.reload
      expect(backend_notification.dismissed_by_id).to eq(@radmin.id)
    end
  end
end
