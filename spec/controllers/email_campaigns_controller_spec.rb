require 'spec_helper'

describe EmailCampaignsController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
  end

  def mock_email_campaign(stubs={})
    (@mock_email_campaign ||= mock_model(EmailCampaign).as_null_object).tap do |email_campaign|
      email_campaign.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all email_campaigns as @email_campaigns" do
      EmailCampaign.stub(:all) { [mock_email_campaign] }
      sign_in @radmin
      get :index
      assigns(:email_campaigns).should eq([mock_email_campaign])
    end
  end

  describe "GET show" do
    it "assigns the requested email_campaign as @email_campaign" do
      EmailCampaign.stub(:find).with("37") { mock_email_campaign }
      sign_in @radmin
      get :show, :id => "37"
      assigns(:email_campaign).should be(mock_email_campaign)
    end
  end

  describe "GET new" do
    it "assigns a new email_campaign as @email_campaign" do
      EmailCampaign.stub(:new) { mock_email_campaign }
      sign_in @radmin
      get :new
      assigns(:email_campaign).should be(mock_email_campaign)
    end
  end

  describe "GET edit" do
    it "assigns the requested email_campaign as @email_campaign" do
      EmailCampaign.stub(:find).with("37") { mock_email_campaign }
      sign_in @radmin
      get :edit, :id => "37"
      assigns(:email_campaign).should be(mock_email_campaign)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created email_campaign as @email_campaign" do
        EmailCampaign.stub(:new).with({'these' => 'params'}) { mock_email_campaign(:save => true) }
        sign_in @radmin
        post :create, :email_campaign => {'these' => 'params'}
        assigns(:email_campaign).should be(mock_email_campaign)
      end

      it "redirects to the created email_campaign" do
        EmailCampaign.stub(:new) { mock_email_campaign(:save => true) }
        sign_in @radmin
        post :create, :email_campaign => {}
        response.should redirect_to(email_campaign_url(mock_email_campaign))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved email_campaign as @email_campaign" do
        EmailCampaign.stub(:new).with({'these' => 'params'}) { mock_email_campaign(:save => false) }
        sign_in @radmin
        post :create, :email_campaign => {'these' => 'params'}
        assigns(:email_campaign).should be(mock_email_campaign)
      end

      it "re-renders the 'new' template" do
        EmailCampaign.stub(:new) { mock_email_campaign(:save => false) }
        sign_in @radmin
        post :create, :email_campaign => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested email_campaign" do
        EmailCampaign.should_receive(:find).with("37") { mock_email_campaign }
        mock_email_campaign.should_receive(:update_attributes).with({'these' => 'params'})
        sign_in @radmin
        put :update, :id => "37", :email_campaign => {'these' => 'params'}
      end

      it "assigns the requested email_campaign as @email_campaign" do
        EmailCampaign.stub(:find) { mock_email_campaign(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:email_campaign).should be(mock_email_campaign)
      end

      it "redirects to the email_campaign" do
        EmailCampaign.stub(:find) { mock_email_campaign(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        response.should redirect_to(email_campaign_url(mock_email_campaign))
      end
    end

    describe "with invalid params" do
      it "assigns the email_campaign as @email_campaign" do
        EmailCampaign.stub(:find) { mock_email_campaign(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:email_campaign).should be(mock_email_campaign)
      end

      it "re-renders the 'edit' template" do
        EmailCampaign.stub(:find) { mock_email_campaign(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested email_campaign" do
      EmailCampaign.should_receive(:find).with("37") { mock_email_campaign }
      mock_email_campaign.should_receive(:destroy)
      sign_in @radmin
      delete :destroy, :id => "37"
    end

    it "redirects to the email_campaigns list" do
      EmailCampaign.stub(:find) { mock_email_campaign }
      sign_in @radmin
      delete :destroy, :id => "1"
      response.should redirect_to(email_campaigns_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page" do
      get :index
      response.should redirect_to('/radmins/sign_in')
    end
  end

end
