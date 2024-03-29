require 'spec_helper'

describe Admin::ProductsController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
    @category = FactoryBot.create(:category)
    @subcategory = FactoryBot.create(:subcategory)
    @product_type = FactoryBot.create(:product_type)
  end

  before(:each) do |example|
    sign_in @radmin unless example.metadata[:skip_before]
  end

  # This should return the minimal set of attributes required to create a valid
  # Product. As you add validations to Product, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      product_code: 'CV001',
      product_type_id: @product_type.id,
      subcategory_id: @subcategory.id,
      category_id: @category.id,
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

  describe 'GET #index' do
    it 'assigns all products as @products' do
      product = Product.create! valid_attributes
      get :index

      expect(assigns(:products)).to eq([product])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested product as @product' do
      product = Product.create! valid_attributes
      get :show, params: { id: product.to_param }

      expect(assigns(:product)).to eq(product)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested product as @product' do
      product = Product.create! valid_attributes
      get :edit, params: { id: product.to_param }

      expect(assigns(:product)).to eq(product)
    end
  end

  describe 'GET new' do
    it 'assigns a new product as @product' do
      get :new

      expect(assigns(:product)).to be_a_new(Product)
    end

    it 'should pre-populate some product fields if a product_code is passed in params' do
      product = FactoryBot.create(:product, category: @category, subcategory: @subcategory)
      get :new, params: { product_code: product.product_code }

      expect(assigns(:product).name).to eq(product.name)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Product' do
        expect {
          post :create, params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
      end

      it 'assigns a newly created product as @product' do
        post :create, params: { product: valid_attributes }

        expect(assigns(:product)).to be_a(Product)
        expect(assigns(:product)).to be_persisted
      end

      it 'redirects to the created product' do
        post :create, params: { product: valid_attributes }

        expect(response).to redirect_to([:admin, Product.last])
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved product as @product' do
        post :create, params: { product: invalid_attributes }

        expect(assigns(:product)).to be_a_new(Product)
      end

      it "re-renders the 'new' template" do
        post :create, params: { product: invalid_attributes }

        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {
          product_code: 'CV002',
          product_type_id: 1,
          subcategory_id: 2
        }
      }

      it 'updates the requested product' do
        product = Product.create! valid_attributes
        put :update, params: { id: product.to_param, product: new_attributes }
        product.reload

        expect(assigns(:product)[:product_code]).to eq('CV002')
        expect(assigns(:product)[:product_type_id]).to eq(1)
        expect(assigns(:product)[:subcategory_id]).to eq(2)
      end

      it 'assigns the requested product as @product' do
        product = Product.create! valid_attributes
        put :update, params: { id: product.to_param, product: valid_attributes }

        expect(assigns(:product)).to eq(product)
      end

      it 'redirects to the product' do
        product = Product.create! valid_attributes
        put :update, params: { id: product.to_param, product: valid_attributes }

        expect(response).to redirect_to([:admin, product])
      end
    end

    context 'with invalid params' do
      it 'assigns the product as @product' do
        product = Product.create! valid_attributes
        put :update, params: { id: product.to_param, product: invalid_attributes }

        expect(assigns(:product)).to eq(product)
      end

      it "re-renders the 'edit' template" do
        product = Product.create! valid_attributes
        put :update, params: { id: product.to_param, product: invalid_attributes }

        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested product' do
      product = Product.create! valid_attributes
      expect {
        delete :destroy, params: { id: product.to_param }
      }.to change(Product, :count).by(-1)
    end

    it 'redirects to the products list' do
      product = Product.create! valid_attributes
      delete :destroy, params: { id: product.to_param }

      expect(response).to redirect_to(admin_products_url)
    end
  end

  describe 'an invalid radmin login' do
    it 'should redirect to radmin login page', :skip_before do
      get :index
      expect(response).to redirect_to('/radmins/sign_in')
    end
  end

  describe 'assign_type' do
    it 'should populate @product_types' do
      @product_type = FactoryBot.create(:product_type, name: 'Models')
      controller.send(:assign_type)

      expect(assigns(:product_types)).to eq([['Instructions', 1], ['Models', 2]])
    end
  end

  describe 'retire_product' do
    context 'for a product with pinterest pins' do
      it 'should retire the product and delete the pins' do
        request.env['HTTP_REFERER'] = '/'
        retired_category = FactoryBot.create(:category, name: 'Retired')
        retired_subcategory = FactoryBot.create(:subcategory, name: 'Retired', code: 'RT')
        product = FactoryBot.create(:product, category_id: @category.id, subcategory_id: @subcategory.id)
        FactoryBot.create(:pin_with_associations, product:)

        expect {
          post :retire_product, params: { product: { id: product.id } }
        }.to change(PinterestPin, :count).by(-1)
      end
    end

    context 'for a product without an etsy listing' do
      it 'should retire the product and not make any calls to etsy' do
        request.env['HTTP_REFERER'] = '/'
        retired_category = FactoryBot.create(:category, name: 'Retired')
        retired_subcategory = FactoryBot.create(:subcategory, name: 'Retired', code: 'RT')
        product = FactoryBot.create(:product, category_id: @category.id, subcategory_id: @subcategory.id)
        expect_any_instance_of(Etsy::Client).to receive(:delete_listing).never
        post :retire_product, params: { product: { id: product.id } }

        expect(assigns(:product)).to eq(product)
        expect(assigns(:product).category_id).to eq(retired_category.id)
        expect(assigns(:product).subcategory_id).to eq(retired_subcategory.id)
        expect(flash[:notice]).to eq('Product retired')
        expect(response).to redirect_to '/'
      end
    end

    context 'for a product with an associated etsy listing' do
      context 'the Etsy client was able to delete the listing' do
        it 'should retire the product and give the admin a notice' do
          request.env['HTTP_REFERER'] = '/'
          retired_category = FactoryBot.create(:category, name: 'Retired')
          retired_subcategory = FactoryBot.create(:subcategory, name: 'Retired', code: 'RT')
          product = FactoryBot.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, etsy_listing_id: 1234)
          allow_any_instance_of(Etsy::Client).to receive(:delete_listing).and_return(true)
          post :retire_product, params: { product: { id: product.id } }

          expect(assigns(:product)).to eq(product)
          expect(assigns(:product).category_id).to eq(retired_category.id)
          expect(assigns(:product).subcategory_id).to eq(retired_subcategory.id)
          expect(flash[:notice]).to eq('Product retired and listing deleted on Etsy')
          expect(response).to redirect_to '/'
        end
      end

      context 'the Etsy client was not able to delete the listing' do
        it 'should retire the product and give the admin an alert' do
          request.env['HTTP_REFERER'] = '/'
          retired_category = FactoryBot.create(:category, name: 'Retired')
          retired_subcategory = FactoryBot.create(:subcategory, name: 'Retired', code: 'RT')
          product = FactoryBot.create(:product, category_id: @category.id, subcategory_id: @subcategory.id, etsy_listing_id: 1234)
          allow_any_instance_of(Etsy::Client).to receive(:delete_listing).and_return(false)
          post :retire_product, params: { product: { id: product.id } }

          expect(assigns(:product)).to eq(product)
          expect(assigns(:product).category_id).to eq(retired_category.id)
          expect(assigns(:product).subcategory_id).to eq(retired_subcategory.id)
          expect(flash[:alert]).to eq('Product retired, but there was a problem deleting the listing on Etsy')
          expect(response).to redirect_to '/'
        end
      end
    end
  end

  describe 'create_etsy_listing' do
    context 'Etsy client was successful' do
      it 'should flash a notice' do
        product = FactoryBot.create(:product)
        allow_any_instance_of(Etsy::Client).to receive(:create_listing).and_return(true)

        post :create_etsy_listing, params: { id: product.id }

        expect(flash[:notice]).to eq('Listing created on Etsy')
        expect(response).to redirect_to(admin_products_path)
      end
    end

    context 'Etsy client was not successful' do
      it 'should flash an alert' do
        product = FactoryBot.create(:product)
        allow_any_instance_of(Etsy::Client).to receive(:create_listing).and_return(false)

        post :create_etsy_listing, params: { id: product.id }

        expect(flash[:alert]).to eq('There was a problem creating the listing on Etsy')
        expect(response).to redirect_to(admin_products_path)
      end
    end
  end

  describe 'update_etsy_listing' do
    context 'Etsy client was successful' do
      it 'should flash a notice' do
        product = FactoryBot.create(:product)
        allow_any_instance_of(Etsy::Client).to receive(:update_listing).and_return(true)

        post :update_etsy_listing, params: { id: product.id }

        expect(flash[:notice]).to eq('Listing updated on Etsy')
        expect(response).to redirect_to(admin_products_path)
      end
    end

    context 'Etsy client was not successful' do
      it 'should flash an alert' do
        product = FactoryBot.create(:product)
        allow_any_instance_of(Etsy::Client).to receive(:update_listing).and_return(false)

        post :update_etsy_listing, params: { id: product.id }

        expect(flash[:alert]).to eq('There was a problem updating the listing on Etsy')
        expect(response).to redirect_to(admin_products_path)
      end
    end
  end

  describe 'destroy_etsy_listing' do
    context 'Etsy client was successful' do
      it 'should flash a notice' do
        product = FactoryBot.create(:product)
        allow_any_instance_of(Etsy::Client).to receive(:delete_listing).and_return(true)

        delete :destroy_etsy_listing, params: { id: product.id }

        expect(flash[:notice]).to eq('Listing deleted on Etsy')
        expect(response).to redirect_to(admin_products_path)
      end
    end

    context 'Etsy client was not successful' do
      it 'should flash an alert' do
        product = FactoryBot.create(:product)
        allow_any_instance_of(Etsy::Client).to receive(:delete_listing).and_return(false)

        delete :destroy_etsy_listing, params: { id: product.id }

        expect(flash[:alert]).to eq('There was a problem deleting the listing on Etsy')
        expect(response).to redirect_to(admin_products_path)
      end
    end
  end

  describe 'update_all_etsy_pdfs' do
    it 'should create a UpdateAllEtsyPdfsJob job and inform the admin' do
      expect(UpdateAllEtsyPdfsJob).to receive(:perform_async)

      post :update_all_etsy_pdfs, params: {}

      expect(flash[:notice]).to eq('This will probably take a few minutes to complete. Once it\'s done, a Notification will be created.')
      expect(response).to redirect_to(admin_products_path)
    end
  end

  describe 'create_pinterest_pin' do
    context 'creates a pin' do
      it 'should flash a nice message' do
        product = FactoryBot.create(:product)
        allow_any_instance_of(Pinterest::Client).to receive(:create_pin).and_return(true)

        post :create_pinterest_pin, params: { id: product.id }

        expect(flash[:notice]).to eq('Pinned to Pinterest')
        expect(response).to redirect_to(admin_products_path)
      end
    end

    context 'cannot create a pin' do
      it 'should flash an alert' do
        product = FactoryBot.create(:product)
        allow_any_instance_of(Pinterest::Client).to receive(:create_pin).and_return(false)

        post :create_pinterest_pin, params: { id: product.id }

        expect(flash[:alert]).to eq('There was a problem creating the pin on Pinterest')
        expect(response).to redirect_to(admin_products_path)
      end
    end
  end
end
