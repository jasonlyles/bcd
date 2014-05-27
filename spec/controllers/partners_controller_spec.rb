require 'spec_helper'

describe PartnersController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
  end

  def mock_partner(stubs={})
    (@mock_partner ||= mock_model(Partner).as_null_object).tap do |partner|
      partner.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all partners as @partners" do
      Partner.stub(:all) { [mock_partner] }
      sign_in @radmin
      get :index
      assigns(:partners).should eq([mock_partner])
    end
  end

  describe "GET show" do
    it "assigns the requested partner as @partner" do
      Partner.stub(:find).with("37") { mock_partner }
      sign_in @radmin
      get :show, :id => "37"
      assigns(:partner).should be(mock_partner)
    end
  end

  describe "GET new" do
    it "assigns a new partner as @partner" do
      Partner.stub(:new) { mock_partner }
      sign_in @radmin
      get :new
      assigns(:partner).should be(mock_partner)
    end
  end

  describe "GET edit" do
    it "assigns the requested partner as @partner" do
      Partner.stub(:find).with("37") { mock_partner }
      sign_in @radmin
      get :edit, :id => "37"
      assigns(:partner).should be(mock_partner)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created partner as @partner" do
        Partner.stub(:new).with({'these' => 'params'}) { mock_partner(:save => true) }
        sign_in @radmin
        post :create, :partner => {'these' => 'params'}
        assigns(:partner).should be(mock_partner)
      end

      it "redirects to the created partner" do
        Partner.stub(:new) { mock_partner(:save => true) }
        sign_in @radmin
        post :create, :partner => {}
        response.should redirect_to(partner_url(mock_partner))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved partner as @partner" do
        Partner.stub(:new).with({'these' => 'params'}) { mock_partner(:save => false) }
        sign_in @radmin
        post :create, :partner => {'these' => 'params'}
        assigns(:partner).should be(mock_partner)
      end

      it "re-renders the 'new' template" do
        Partner.stub(:new) { mock_partner(:save => false) }
        sign_in @radmin
        post :create, :partner => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested partner" do
        Partner.should_receive(:find).with("37") { mock_partner }
        mock_partner.should_receive(:update_attributes).with({'these' => 'params'})
        sign_in @radmin
        put :update, :id => "37", :partner => {'these' => 'params'}
      end

      it "assigns the requested partner as @partner" do
        Partner.stub(:find) { mock_partner(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:partner).should be(mock_partner)
      end

      it "redirects to the partner" do
        Partner.stub(:find) { mock_partner(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        response.should redirect_to(partner_url(mock_partner))
      end
    end

    describe "with invalid params" do
      it "assigns the partner as @partner" do
        Partner.stub(:find) { mock_partner(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:partner).should be(mock_partner)
      end

      it "re-renders the 'edit' template" do
        Partner.stub(:find) { mock_partner(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested partner" do
      Partner.should_receive(:find).with("37") { mock_partner }
      mock_partner.should_receive(:destroy)
      sign_in @radmin
      delete :destroy, :id => "37"
    end

    it "redirects to the partners list" do
      Partner.stub(:find) { mock_partner }
      sign_in @radmin
      delete :destroy, :id => "1"
      response.should redirect_to(partners_url)
    end

    it "should redirect to the partners list if partner cant be deleted due to an advertising campaign with that partner that went live" do
      Partner.should_receive(:find).with("1") {mock_partner}
      mock_partner.should_receive(:destroy).and_return(nil)
      sign_in @radmin
      delete :destroy, :id => '1'

      flash[:alert].should eq("Sorry. You can't delete a partner that has advertising campaigns that have been used.")
      response.should redirect_to(partners_url)
    end
  end

end
