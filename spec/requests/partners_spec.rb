require 'spec_helper'

describe "Partners" do

  def login(radmin)
    post_via_redirect radmin_session_path, 'radmin[email]' => radmin.email, 'radmin[password]' => radmin.password
  end

  describe "GET /partners" do
    it "works!" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get partners_path
      response.status.should be(302)
      radmin = Radmin.create(:email => "lylesjt@gmail.com", :password => 'password', :password_confirmation => 'password')
      login radmin
      get partners_path
      response.status.should be(200)
    end
  end
end

