require 'spec_helper'

describe ProductsController do

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
  # Product. As you add validations to Product, be sure to
  # adjust the attributes here as well.
=begin
    validates :product_code, :uniqueness => true, :presence => true
  validates :product_type_id, :presence => true
  validates :subcategory_id, :presence => true
  validates :category_id, :presence => true
  validates :description, :presence => true, :length => {:minimum => 100, :maximum => 900}
  validates :price, :presence => true, :numericality => true
  validates :price, :price_greater_than_zero => true
  validates :price, :price_is_zero_for_freebies => true
  validates :product_code, :product_code_matches_pattern => true
  validates :name, :presence => true, :uniqueness => true
  validates :tweet, :length => {:maximum => 97}
  validates :discount_percentage, :numericality => true, :allow_blank => true
  validates :discount_percentage, :inclusion => {:in => 0..90, :message => "Percentage must be between 0 and 90"}, :allow_blank => true
  #This line calls a custom validator that looks to make sure that there is a pdf attached to this object before
  #letting this product be made available to the public
  validates :ready_for_public, :pdf_exists => true
=end
  let(:valid_attributes) {
    {
        product_code: 'CV001',
        product_type_id: 1,
        subcategory_id: 1,
        category_id: 1,
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis vitae magna eget massa nunc.',
        price: 5,
        name: 'Awesome Product'
    }
  }

  let(:invalid_attributes) {
    {
        description: 'Too short description',
        product_type_id: 1,
        subcategory_id: nil,
        product_code: 'CV001'
    }
  }

  describe "GET #index" do
    it "assigns all products as @products" do
      product = Product.create! valid_attributes
      get :index

      expect(assigns(:products)).to eq([product])
    end
  end

  describe "GET #show" do
    it "assigns the requested product as @product" do
      product = Product.create! valid_attributes
      get :show, id: product.to_param

      expect(assigns(:product)).to eq(product)
    end
  end

  describe "GET #edit" do
    it "assigns the requested product as @product" do
      product = Product.create! valid_attributes
      get :edit, id: product.to_param

      expect(assigns(:product)).to eq(product)
    end
  end

  describe "GET new" do
    it "assigns a new product as @product" do
      get :new

      expect(assigns(:product)).to be_a_new(Product)
    end

    it "should pre-populate some product fields if a product_code is passed in params" do
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      get :new, :product_code => product.product_code

      expect(assigns(:product).name).to eq(product.name)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Product" do
        expect {
          post :create, product: valid_attributes
        }.to change(Product, :count).by(1)
      end

      it "assigns a newly created product as @product" do
        post :create, product: valid_attributes

        expect(assigns(:product)).to be_a(Product)
        expect(assigns(:product)).to be_persisted
      end

      it "redirects to the created product" do
        post :create, product: valid_attributes

        expect(response).to redirect_to(Product.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved product as @product" do
        post :create, product: invalid_attributes

        expect(assigns(:product)).to be_a_new(Product)
      end

      it "re-renders the 'new' template" do
        post :create, product: invalid_attributes

        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            product_code: 'CV002',
            product_type_id: 1,
            subcategory_id: 2,
        }
      }

      it "updates the requested product" do
        product = Product.create! valid_attributes
        put :update, id: product.to_param, product: new_attributes
        product.reload

        expect(assigns(:product)[:product_code]).to eq('CV002')
        expect(assigns(:product)[:product_type_id]).to eq(1)
        expect(assigns(:product)[:subcategory_id]).to eq(2)
      end

      it "assigns the requested product as @product" do
        product = Product.create! valid_attributes
        put :update, id: product.to_param, product: valid_attributes

        expect(assigns(:product)).to eq(product)
      end

      it "redirects to the product" do
        product = Product.create! valid_attributes
        put :update, id: product.to_param, product: valid_attributes

        expect(response).to redirect_to(product)
      end
    end

    context "with invalid params" do
      it "assigns the product as @product" do
        product = Product.create! valid_attributes
        put :update, id: product.to_param, product: invalid_attributes

        expect(assigns(:product)).to eq(product)
      end

      it "re-renders the 'edit' template" do
        product = Product.create! valid_attributes
        put :update, id: product.to_param, product: invalid_attributes

        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested product" do
      product = Product.create! valid_attributes
      expect {
        delete :destroy, id: product.to_param
      }.to change(Product, :count).by(-1)
    end

    it "redirects to the products list" do
      product = Product.create! valid_attributes
      delete :destroy, id: product.to_param

      expect(response).to redirect_to(products_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page", :skip_before do
      get :index
      expect(response).to redirect_to('/radmins/sign_in')
    end
  end

  describe 'get_type' do
    it "should populate @product_types" do
      @product_type = FactoryGirl.create(:product_type, :name => 'Models')
      controller.send(:get_type)

      expect(assigns(:product_types)).to eq([["Instructions", 1], ["Models", 2]])
    end
  end

  describe "retire_product" do
    it "should retire the product" do
      request.env["HTTP_REFERER"] = '/'
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      retired_category = FactoryGirl.create(:category, :name => 'Retired')
      retired_subcategory = FactoryGirl.create(:subcategory, :name => 'Retired', :code => 'RT')
      product = FactoryGirl.create(:product, :category_id => category.id, :subcategory_id => subcategory.id)
      post :retire_product, :product => {:id => product.id}

      expect(assigns(:product)).to eq(product)
      expect(assigns(:product).category_id).to eq(retired_category.id)
      expect(assigns(:product).subcategory_id).to eq(retired_subcategory.id)
      expect(response).to redirect_to '/'
    end
  end
end