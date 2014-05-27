require 'spec_helper'

describe "Categories" do

  def login(radmin)
    post_via_redirect radmin_session_path, 'radmin[email]' => radmin.email, 'radmin[password]' => radmin.password
  end

  describe "GET /categories" do
    it "works!" do

      get categories_path
      response.status.should be(302)
      radmin = Radmin.create(:email=>"lylesjt@gmail.com", :password=>'password', :password_confirmation=>'password')
      login radmin
      get categories_path
      response.status.should be(200)
    end
  end
end
