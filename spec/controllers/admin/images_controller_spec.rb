require 'spec_helper'

describe Admin::ImagesController do
  before do
    @radmin ||= FactoryGirl.create(:radmin)
    @product_type = FactoryGirl.create(:product_type)
  end

  before(:each) do |example|
    unless example.metadata[:skip_before]
      sign_in @radmin
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # Image. As you add validations to Image, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        category_id: 1,
        product_id: 2
    }
  }

  let(:invalid_attributes) {
    {
        category_id: nil,
        product_id: nil
    }
  }

  describe "GET #index" do
    it "assigns all images as @images" do
      image = Image.create! valid_attributes
      get :index

      expect(assigns(:images)).to eq([image])
    end
  end

  describe "GET #show" do
    it "assigns the requested image as @image" do
      image = Image.create! valid_attributes
      get :show, id: image.to_param

      expect(assigns(:image)).to eq(image)
    end
  end

  describe "GET #edit" do
    it "assigns the requested image as @image" do
      image = Image.create! valid_attributes
      get :edit, id: image.to_param

      expect(assigns(:image)).to eq(image)
    end
  end


  describe "GET new" do
    it "assigns a new image as @image" do
      get :new

      expect(assigns(:image)).to be_a_new(Image)
    end

    it "gets some default values for a new image if :product_id is passed in the params" do
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product, :product_code => 'ZZ001')
      get :new, :product_id => product.id

      expect(assigns(:image).product.product_code).to eq('ZZ001')
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Image" do
        expect {
          post :create, image: valid_attributes
        }.to change(Image, :count).by(1)
      end

      it "assigns a newly created image as @image" do
        post :create, image: valid_attributes

        expect(assigns(:image)).to be_a(Image)
        expect(assigns(:image)).to be_persisted
      end

      it "redirects to the created image" do
        post :create, image: valid_attributes

        expect(response).to redirect_to([:admin, Image.last])
      end
    end

    context "with invalid params" do
# I don't presently have any validations on image, since everything I would set is optional
=begin
      it "assigns a newly created but unsaved image as @image" do
        post :create, image: invalid_attributes

        expect(assigns(:image)).to be_a_new(Image)
      end
=end
# I don't presently have any validations on image, since everything I would set is optional
=begin
      it "re-renders the 'new' template" do
        post :create, image: invalid_attributes

        expect(response).to render_template("new")
      end
=end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            category_id: 2,
            product_id: 3
        }
      }

      it "updates the requested image" do
        image = Image.create! valid_attributes
        put :update, id: image.to_param, image: new_attributes
        image.reload

        expect(assigns(:image)[:category_id]).to eq(2)
        expect(assigns(:image)[:product_id]).to eq(3)
      end

      it "assigns the requested image as @image" do
        image = Image.create! valid_attributes
        put :update, id: image.to_param, image: valid_attributes

        expect(assigns(:image)).to eq(image)
      end

      it "redirects to the image" do
        image = Image.create! valid_attributes
        put :update, id: image.to_param, image: valid_attributes

        expect(response).to redirect_to([:admin, image])
      end
    end

    context "with invalid params" do
      it "assigns the image as @image" do
        image = Image.create! valid_attributes
        put :update, id: image.to_param, image: invalid_attributes

        expect(assigns(:image)).to eq(image)
      end
# I don't presently have any validations on image, since everything I would set is optional
=begin
      it "re-renders the 'edit' template" do
        image = Image.create! valid_attributes
        put :update, id: image.to_param, image: invalid_attributes

        expect(response).to render_template("edit")
      end
=end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested image" do
      image = Image.create! valid_attributes
      expect {
        delete :destroy, id: image.to_param
      }.to change(Image, :count).by(-1)
    end

    it "redirects to the images list" do
      image = Image.create! valid_attributes
      delete :destroy, id: image.to_param

      expect(response).to redirect_to(admin_images_url)
    end
  end

  describe "an invalid radmin login", :skip_before do
    it "should redirect to radmin login page" do
      get :index
      expect(response).to redirect_to('/radmins/sign_in')
    end
  end

  describe "get_products" do
    it "should return a list of products in a nice format" do
      category = FactoryGirl.create(:category)
      subcat = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      controller.send(:get_products)

      expect(assigns(:products)).to eq([["Colonial Revival House", 1]])
    end
  end
end
