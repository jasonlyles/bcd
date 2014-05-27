require 'spec_helper'

describe ProductsController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
    @product_type = FactoryGirl.create(:product_type)
  end

  def mock_product(stubs={})
    (@mock_product ||= mock_model(Product).as_null_object).tap do |product|
      product.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all products as @products" do
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product1 = FactoryGirl.create(:product)
      product2 = FactoryGirl.create(:product, :name => 'Fake', :product_code => 'CB099')
      sign_in @radmin
      get :index

      assigns(:products).length.should eq(2)
    end
  end

  describe "GET show" do
    it "assigns the requested product as @product" do
      Product.stub(:find).with("37") { mock_product }
      sign_in @radmin
      get :show, :id => "37"
      assigns(:product).should be(mock_product)
    end
  end

  describe "GET new" do
    it "assigns a new product as @product" do
      Product.stub(:new) { mock_product }
      sign_in @radmin
      get :new
      assigns(:product).should be(mock_product)
    end

    it "should pre-populate some product fields if a product_code is passed in params" do
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      sign_in @radmin
      get :new, :product_code => product.product_code

      (assigns(:product).name).should eq(product.name)
    end
  end

  describe "GET edit" do
    it "assigns the requested product as @product" do
      Product.stub(:find).with("37") { mock_product }
      sign_in @radmin
      get :edit, :id => "37"
      assigns(:product).should be(mock_product)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created product as @product" do
        Product.stub(:new).with({'these' => 'params'}) { mock_product(:save => true) }
        sign_in @radmin
        post :create, :product => {'these' => 'params'}
        assigns(:product).should be(mock_product)
      end

      it "redirects to the created product" do
        Product.stub(:new) { mock_product(:save => true) }
        sign_in @radmin
        post :create, :product => {}
        response.should redirect_to(product_url(mock_product))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved product as @product" do
        Product.stub(:new).with({'these' => 'params'}) { mock_product(:save => false) }
        sign_in @radmin
        post :create, :product => {'these' => 'params'}
        assigns(:product).should be(mock_product)
      end

      it "re-renders the 'new' template" do
        Product.stub(:new) { mock_product(:save => false) }
        sign_in @radmin
        post :create, :product => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested product" do
        Product.should_receive(:find).with("37") { mock_product }
        mock_product.should_receive(:update_attributes).with({'these' => 'params'})
        sign_in @radmin
        put :update, :id => "37", :product => {'these' => 'params'}
      end

      it "assigns the requested product as @product" do
        Product.stub(:find) { mock_product(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:product).should be(mock_product)
      end

      it "redirects to the product" do
        Product.stub(:find) { mock_product(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        response.should redirect_to(product_url(mock_product))
      end
    end

    describe "with invalid params" do
      it "assigns the product as @product" do
        Product.stub(:find) { mock_product(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:product).should be(mock_product)
      end

      it "re-renders the 'edit' template" do
        Product.stub(:find) { mock_product(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested product" do
      Product.should_receive(:find).with("37") { mock_product }
      mock_product.should_receive(:destroy)
      sign_in @radmin
      delete :destroy, :id => "37"
    end

    it "redirects to the products list" do
      Product.stub(:find) { mock_product }
      sign_in @radmin
      delete :destroy, :id => "1"
      response.should redirect_to(products_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page" do
      get :index
      response.should redirect_to('/radmins/sign_in')
    end
  end

  describe 'get_categories' do
    it "should populate @categories" do
      FactoryGirl.create(:category)
      controller.send(:get_categories)

      assigns(:categories).should == [["City", 1]]
    end
  end

  describe 'get_type' do
    it "should populate @product_types" do
      @product_type = FactoryGirl.create(:product_type, :name => 'Models')
      controller.send(:get_type)

      assigns(:product_types).should == [["Instructions", 1], ["Models", 2]]
    end
  end

  describe "retire_product" do
    it "should retire the product" do
      sign_in @radmin
      request.env["HTTP_REFERER"] = '/'
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      retired_category = FactoryGirl.create(:category, :name => 'Retired')
      retired_subcategory = FactoryGirl.create(:subcategory, :name => 'Retired', :code => 'RT')
      product = FactoryGirl.create(:product, :category_id => category.id, :subcategory_id => subcategory.id)
      post :retire_product, :product => {:id => product.id}
      assigns(:product).should eq(product)
      assigns(:product).category_id.should eq(retired_category.id)
      assigns(:product).subcategory_id.should eq(retired_subcategory.id)
      response.should redirect_to '/'
    end
  end
end
