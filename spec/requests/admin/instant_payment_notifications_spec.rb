require 'spec_helper'

RSpec.describe "InstantPaymentNotifications", type: :request do

  def login(radmin)
    post_via_redirect radmin_session_path, 'radmin[email]' => radmin.email, 'radmin[password]' => radmin.password
  end

  describe "GET /instant_payment_notifications" do
    it "works! (now write some real specs)" do
      get admin_instant_payment_notifications_path
      expect(response).to have_http_status(302)
      radmin = Radmin.create(:email=>"lylesjt@gmail.com", :password=>'password', :password_confirmation=>'password')
      login radmin
      get admin_instant_payment_notifications_path
      expect(response).to have_http_status(200)
    end
  end
end
