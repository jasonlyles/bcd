require 'spec_helper'

describe "Products" do

  def login(radmin)
    post_via_redirect radmin_session_path, 'radmin[email]' => radmin.email, 'radmin[password]' => radmin.password
  end

  describe "GET /products" do
    it "works!" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get products_path
      expect(response.status).to eq(302)
      radmin = Radmin.create(:email=>"lylesjt@gmail.com", :password=>'password', :password_confirmation=>'password')
      login radmin
      get products_path
      expect(response.status).to eq(200)
    end
  end
end
