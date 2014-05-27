require 'spec_helper'

describe UpdatesController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
  end

  def mock_update(stubs={})
    (@mock_update ||= mock_model(Update).as_null_object).tap do |update|
      update.stub(stubs) unless stubs.empty?
    end
  end

  def factory_girl_mock
    2.times do
      FactoryGirl.create(:update)
    end
    Update.order('created_at desc')
  end

  describe "GET index" do
    it "assigns all updates as @updates" do
      FactoryGirl.create(:update)
      FactoryGirl.create(:update)
      sign_in @radmin
      get :index

      assigns(:updates).length.should eq(2)
    end
  end

  describe "GET show" do
    it "assigns the requested update as @update" do
      Update.stub(:find).with("37") { mock_update }
      sign_in @radmin
      get :show, :id => "37"
      assigns(:update).should be(mock_update)
    end
  end

  describe "GET new" do
    it "assigns a new update as @update" do
      Update.stub(:new) { mock_update }
      sign_in @radmin
      get :new
      assigns(:update).should be(mock_update)
    end
  end

  describe "GET edit" do
    it "assigns the requested update as @update" do
      Update.stub(:find).with("37") { mock_update }
      sign_in @radmin
      get :edit, :id => "37"
      assigns(:update).should be(mock_update)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created update as @update" do
        Update.stub(:new).with({'these' => 'params'}) { mock_update(:save => true) }
        sign_in @radmin
        post :create, :update => {'these' => 'params'}
        assigns(:update).should be(mock_update)
      end

      it "redirects to the created update" do
        Update.stub(:new) { mock_update(:save => true) }
        sign_in @radmin
        post :create, :update => {}
        response.should redirect_to(update_url(mock_update))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved update as @update" do
        Update.stub(:new).with({'these' => 'params'}) { mock_update(:save => false) }
        sign_in @radmin
        post :create, :update => {'these' => 'params'}
        assigns(:update).should be(mock_update)
      end

      it "re-renders the 'new' template" do
        Update.stub(:new) { mock_update(:save => false) }
        sign_in @radmin
        post :create, :update => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested update" do
        Update.should_receive(:find).with("37") { mock_update }
        mock_update.should_receive(:update_attributes).with({'these' => 'params'})
        sign_in @radmin
        put :update, :id => "37", :update => {'these' => 'params'}
      end

      it "assigns the requested update as @update" do
        Update.stub(:find) { mock_update(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:update).should be(mock_update)
      end

      it "redirects to the update" do
        Update.stub(:find) { mock_update(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        response.should redirect_to(update_url(mock_update))
      end
    end

    describe "with invalid params" do
      it "assigns the update as @update" do
        Update.stub(:find) { mock_update(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:update).should be(mock_update)
      end

      it "re-renders the 'edit' template" do
        Update.stub(:find) { mock_update(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested update" do
      Update.should_receive(:find).with("37") { mock_update }
      mock_update.should_receive(:destroy)
      sign_in @radmin
      delete :destroy, :id => "37"
    end

    it "redirects to the updates list" do
      Update.stub(:find) { mock_update }
      sign_in @radmin
      delete :destroy, :id => "1"
      response.should redirect_to(updates_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page" do
      get :index
      response.should redirect_to('/radmins/sign_in')
    end
  end

end
