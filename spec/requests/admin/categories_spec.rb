require 'spec_helper'

describe "Categories" do

  def login(radmin)
    post_via_redirect radmin_session_path, 'radmin[email]' => radmin.email, 'radmin[password]' => radmin.password
  end

  describe "GET /categories" do
    it "works!" do

      get admin_categories_path
      expect(response.status).to eq(302)
      radmin = Radmin.create(:email=>"lylesjt@gmail.com", :password=>'password', :password_confirmation=>'password')
      login radmin
      get admin_categories_path
      expect(response.status).to eq(200)
    end
  end
end