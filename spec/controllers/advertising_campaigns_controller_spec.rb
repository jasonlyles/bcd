require 'spec_helper'

describe AdvertisingCampaignsController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
  end

  def mock_advertising_campaign(stubs={})
    (@mock_advertising_campaign ||= mock_model(AdvertisingCampaign).as_null_object).tap do |advertising_campaign|
      advertising_campaign.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all advertising_campaigns as @advertising_campaigns" do
      AdvertisingCampaign.stub(:all) { [mock_advertising_campaign] }
      sign_in @radmin
      get :index
      assigns(:advertising_campaigns).should eq([mock_advertising_campaign])
    end
  end

  describe "GET show" do
    it "assigns the requested advertising_campaign as @advertising_campaign" do
      AdvertisingCampaign.stub(:find).with("37") { mock_advertising_campaign }
      sign_in @radmin
      get :show, :id => "37"
      assigns(:advertising_campaign).should be(mock_advertising_campaign)
    end
  end

  describe "GET new" do
    it "assigns a new advertising_campaign as @advertising_campaign" do
      AdvertisingCampaign.stub(:new) { mock_advertising_campaign }
      sign_in @radmin
      get :new
      assigns(:advertising_campaign).should be(mock_advertising_campaign)
    end
  end

  describe "GET edit" do
    it "assigns the requested advertising_campaign as @advertising_campaign" do
      AdvertisingCampaign.stub(:find).with("37") { mock_advertising_campaign }
      sign_in @radmin
      get :edit, :id => "37"
      assigns(:advertising_campaign).should be(mock_advertising_campaign)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created advertising_campaign as @advertising_campaign" do
        AdvertisingCampaign.stub(:new).with({'these' => 'params'}) { mock_advertising_campaign(:save => true) }
        sign_in @radmin
        post :create, :advertising_campaign => {'these' => 'params'}
        assigns(:advertising_campaign).should be(mock_advertising_campaign)
      end

      it "redirects to the created advertising_campaign" do
        AdvertisingCampaign.stub(:new) { mock_advertising_campaign(:save => true) }
        sign_in @radmin
        post :create, :advertising_campaign => {}
        response.should redirect_to(advertising_campaign_url(mock_advertising_campaign))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved advertising_campaign as @advertising_campaign" do
        AdvertisingCampaign.stub(:new).with({'these' => 'params'}) { mock_advertising_campaign(:save => false) }
        sign_in @radmin
        post :create, :advertising_campaign => {'these' => 'params'}
        assigns(:advertising_campaign).should be(mock_advertising_campaign)
      end

      it "re-renders the 'new' template" do
        AdvertisingCampaign.stub(:new) { mock_advertising_campaign(:save => false) }
        sign_in @radmin
        post :create, :advertising_campaign => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested advertising_campaign" do
        AdvertisingCampaign.should_receive(:find).with("37") { mock_advertising_campaign }
        mock_advertising_campaign.should_receive(:update_attributes).with({'these' => 'params'})
        sign_in @radmin
        put :update, :id => "37", :advertising_campaign => {'these' => 'params'}
      end

      it "assigns the requested advertising_campaign as @advertising_campaign" do
        AdvertisingCampaign.stub(:find) { mock_advertising_campaign(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:advertising_campaign).should be(mock_advertising_campaign)
      end

      it "redirects to the advertising_campaign" do
        AdvertisingCampaign.stub(:find) { mock_advertising_campaign(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        response.should redirect_to(advertising_campaign_url(mock_advertising_campaign))
      end
    end

    describe "with invalid params" do
      it "assigns the advertising_campaign as @advertising_campaign" do
        AdvertisingCampaign.stub(:find) { mock_advertising_campaign(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:advertising_campaign).should be(mock_advertising_campaign)
      end

      it "re-renders the 'edit' template" do
        AdvertisingCampaign.stub(:find) { mock_advertising_campaign(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested advertising_campaign" do
      AdvertisingCampaign.should_receive(:find).with("37") { mock_advertising_campaign }
      mock_advertising_campaign.should_receive(:destroy)
      sign_in @radmin
      delete :destroy, :id => "37"
    end

    it "redirects to the advertising_campaigns list" do
      AdvertisingCampaign.stub(:find) { mock_advertising_campaign }
      sign_in @radmin
      delete :destroy, :id => "1"
      response.should redirect_to(advertising_campaigns_url)
    end
  end

end
