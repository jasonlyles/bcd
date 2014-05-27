require 'spec_helper'

describe ImagesController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
    @product_type = FactoryGirl.create(:product_type)
  end

  def mock_image(stubs={})
    (@mock_image ||= mock_model(Image).as_null_object).tap do |image|
      image.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all images as @images" do
      image1 = FactoryGirl.create(:image)
      image2 = FactoryGirl.create(:image)
      sign_in @radmin
      get :index
      assigns(:images).length.should eq(2)
    end
  end

  describe "GET show" do
    it "assigns the requested image as @image" do
      Image.stub(:find).with("37") { mock_image }
      sign_in @radmin
      get :show, :id => "37"
      assigns(:image).should be(mock_image)
    end
  end

  describe "GET new" do
    it "assigns a new image as @image" do
      Image.stub(:new) { mock_image }
      sign_in @radmin
      get :new
      assigns(:image).should be(mock_image)
    end

    it "gets some default values for a new image if :product_id is passed in the params" do
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product, :product_code => 'ZZ001')
      sign_in @radmin
      get :new, :product_id => product.id

      assigns(:image).product.product_code.should eq('ZZ001')
    end
  end

  describe "GET edit" do
    it "assigns the requested image as @image" do
      Image.stub(:find).with("37") { mock_image }
      sign_in @radmin
      get :edit, :id => "37"
      assigns(:image).should be(mock_image)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created image as @image" do
        Image.stub(:new).with({'these' => 'params'}) { mock_image(:save => true) }
        sign_in @radmin
        post :create, :image => {'these' => 'params'}
        assigns(:image).should be(mock_image)
      end

      it "redirects to the created image" do
        Image.stub(:new) { mock_image(:save => true) }
        sign_in @radmin
        post :create, :image => {}
        response.should redirect_to(image_url(mock_image))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved image as @image" do
        Image.stub(:new).with({'these' => 'params'}) { mock_image(:save => false) }
        sign_in @radmin
        post :create, :image => {'these' => 'params'}
        assigns(:image).should be(mock_image)
      end

      it "re-renders the 'new' template" do
        Image.stub(:new) { mock_image(:save => false) }
        sign_in @radmin
        post :create, :image => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested image" do
        Image.should_receive(:find).with("37") { mock_image }
        mock_image.should_receive(:update_attributes).with({'these' => 'params'})
        sign_in @radmin
        put :update, :id => "37", :image => {'these' => 'params'}
      end

      it "assigns the requested image as @image" do
        Image.stub(:find) { mock_image(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:image).should be(mock_image)
      end

      it "redirects to the image" do
        Image.stub(:find) { mock_image(:update_attributes => true) }
        sign_in @radmin
        put :update, :id => "1"
        response.should redirect_to(image_url(mock_image))
      end
    end

    describe "with invalid params" do
      it "assigns the image as @image" do
        Image.stub(:find) { mock_image(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        assigns(:image).should be(mock_image)
      end

      it "re-renders the 'edit' template" do
        Image.stub(:find) { mock_image(:update_attributes => false) }
        sign_in @radmin
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested image" do
      Image.should_receive(:find).with("37") { mock_image }
      mock_image.should_receive(:destroy)
      sign_in @radmin
      delete :destroy, :id => "37"
    end

    it "redirects to the images list" do
      Image.stub(:find) { mock_image }
      sign_in @radmin
      delete :destroy, :id => "1"
      response.should redirect_to(images_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page" do
      get :index
      response.should redirect_to('/radmins/sign_in')
    end
  end

  describe "get_products" do
    it "should return a list of products in a nice format" do
      category = FactoryGirl.create(:category)
      subcat = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      controller.send(:get_products)

      assigns(:products).should == [["Colonial Revival House", 1]]
    end
  end
end
