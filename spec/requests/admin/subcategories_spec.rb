require 'spec_helper'

describe "Subcategories" do

  def login(radmin)
    post_via_redirect radmin_session_path, 'radmin[email]' => radmin.email, 'radmin[password]' => radmin.password
  end

  describe "GET /subcategories" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get admin_subcategories_path
      expect(response.status).to eq(302)
      radmin = Radmin.create(:email=>"lylesjt@gmail.com", :password=>'password', :password_confirmation=>'password')
      login radmin
      get admin_subcategories_path
      expect(response.status).to eq(200)
    end
  end
end
