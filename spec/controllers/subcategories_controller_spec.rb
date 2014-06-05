require 'spec_helper'

describe SubcategoriesController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
    @product_type = FactoryGirl.create(:product_type)
  end

  def mock_subcategory(stubs={})
    (@mock_subcategory ||= mock_model(Subcategory).as_null_object).tap do |subcategory|
      subcategory.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all subcategories as @subcategories" do
      Subcategory.stub(:all) { [mock_subcategory] }
      sign_in @radmin
      get :index
      assigns(:subcategories).should eq([mock_subcategory])
    end
  end

  describe "GET show" do
    it "assigns the requested subcategory as @subcategory" do
      Subcategory.stub(:find).with("37") { mock_subcategory }
      sign_in @radmin
      get :show, :id => "37"
      assigns(:subcategory).should be(mock_subcategory)
    end
  end

  describe "GET new" do
    it "assigns a new subcategory as @subcategory" do
      Subcategory.stub(:new) { mock_subcategory }
      sign_in @radmin
      get :new
      assigns(:subcategory).should be(mock_subcategory)
    end
  end

  describe "GET edit" do
    it "assigns the requested subcategory as @subcategory" do
      Subcategory.stub(:find).with("37") { mock_subcategory }
      sign_in @radmin
      get :edit, :id => "37"
      assigns(:subcategory).should be(mock_subcategory)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created subcategory as @subcategory" do
        Subcategory.stub(:new).with({'these' => 'params'}) { mock_subcategory(:save => true) }
        sign_in @radmin
        post :create, :subcategory => {'these' => 'params'}
        assigns(:subcategory).should be(mock_subcategory)
      end

      it "redirects to the created subcategory" do
        Subcategory.stub(:new) { mock_subcategory(:save => true) }
        sign_in @radmin
        post :create, :subcategory => {}
        response.should redirect_to(subcategory_url(mock_subcategory))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved subcategory as @subcategory" do
        Subcategory.stub(:new).with({'these' => 'params'}) { mock_subcategory(:save => false) }
        sign_in @radmin
        post :create, :subcategory => {'these' => 'params'}
        assigns(:subcategory).should be(mock_subcategory)
      end

      it "re-renders the 'new' template" do
        Subcategory.stub(:new) { mock_subcategory(:save => false) }
        sign_in @radmin
        post :create, :subcategory => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested subcategory" do
        Subcategory.should_receive(:find).with("37") { mock_subcategory }
        mock_subcategory.should_receive(:update_attributes).with({'these' => 'params'})
        sign_in @radmin
        put :update, :id => "37", :subcategory => {'these' => 'params'}
      end

      it "assigns the requested subcategory as @subcategory" do
        Subcategory.stub(:find) { mock_subcategory(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:subcategory).should be(mock_subcategory)
      end

      it "redirects to the subcategory" do
        Subcategory.stub(:find) { mock_subcategory(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        response.should redirect_to(subcategory_url(mock_subcategory))
      end
    end

    describe "with invalid params" do
      it "assigns the subcategory as @subcategory" do
        Subcategory.stub(:find) { mock_subcategory(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:subcategory).should be(mock_subcategory)
      end

      it "re-renders the 'edit' template" do
        Subcategory.stub(:find) { mock_subcategory(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested subcategory" do
      Subcategory.should_receive(:find).with("37") { mock_subcategory }
      mock_subcategory.should_receive(:destroy)
      sign_in @radmin
      delete :destroy, :id => "37"
    end

    it "redirects to the subcategories list" do
      Subcategory.stub(:find) { mock_subcategory }
      sign_in @radmin
      delete :destroy, :id => "1"
      response.should redirect_to(subcategories_url)
    end

    it "should not destroy a subcategory that has products" do
      @category = FactoryGirl.create(:category)
      @subcat = FactoryGirl.create(:subcategory_with_products)
      sign_in @radmin
      delete :destroy, :id => @subcat.id
      response.should redirect_to(subcategories_url)
      flash[:alert].should == "You can't delete this subcategory while it has products. Delete or reassign the products and try again."
    end
  end

  describe "model_code" do
    it "should get a suggested model_code" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      sign_in @radmin
      get :model_code, :id => @subcategory.id, format: :json

      #really I think I need to figure out some way to test that this is getting rendered in json, but I don't know how to test for that yet.
      assigns(:model_code).should == "#{@subcategory.code}002"
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page" do
      get :index
      response.should redirect_to('/radmins/sign_in')
    end
  end
end
