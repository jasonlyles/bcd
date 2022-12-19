require 'spec_helper'

describe "ProductTypes" do
  def login(radmin)
    post_via_redirect radmin_session_path, 'radmin[email]' => radmin.email, 'radmin[password]' => radmin.password
  end

  describe "GET /product_types" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      radmin = Radmin.create(:email => "lylesjt@gmail.com", :password => 'password', :password_confirmation => 'password')
      login radmin
      get admin_product_types_path
      expect(response.status).to eq(200)
    end
  end
end
