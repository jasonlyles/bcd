require 'spec_helper'

describe "Updates" do

  def login(radmin)
    post_via_redirect radmin_session_path, 'radmin[email]' => radmin.email, 'radmin[password]' => radmin.password
  end

  describe "GET /updates" do
    it "works! (now write some real specs)" do
      get updates_path
      response.status.should be(302)
      radmin = Radmin.create(:email=>"lylesjt@gmail.com", :password=>'password', :password_confirmation=>'password')
      login radmin
      get updates_path
      response.status.should be(200)
    end
  end
end
