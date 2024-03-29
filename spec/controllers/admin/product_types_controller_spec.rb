require 'spec_helper'

describe Admin::ProductTypesController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
  end

  before(:each) do
    sign_in @radmin
  end

  # This should return the minimal set of attributes required to create a valid
  # ProductType. As you add validations to ProductType, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { 'name' => 'Instructions' } }

  describe 'GET index' do
    it 'assigns all product_types as @product_types' do
      product_type = ProductType.create! valid_attributes
      get :index

      expect(assigns(:product_types)).to eq([product_type])
    end
  end

  describe 'GET show' do
    it 'assigns the requested product_type as @product_type' do
      product_type = ProductType.create! valid_attributes
      get :show, params: { id: product_type.to_param }

      expect(assigns(:product_type)).to eq(product_type)
    end
  end

  describe 'GET new' do
    it 'assigns a new product_type as @product_type' do
      get :new

      expect(assigns(:product_type)).to be_a_new(ProductType)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested product_type as @product_type' do
      product_type = ProductType.create! valid_attributes
      get :edit, params: { id: product_type.to_param }

      expect(assigns(:product_type)).to eq(product_type)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new ProductType' do
        expect {
          post :create, params: { product_type: valid_attributes }
        }.to change(ProductType, :count).by(1)
      end

      it 'assigns a newly created product_type as @product_type' do
        post :create, params: { product_type: valid_attributes }

        expect(assigns(:product_type)).to be_a(ProductType)
        expect(assigns(:product_type)).to be_persisted
      end

      it 'redirects to the created product_type' do
        post :create, params: { product_type: valid_attributes }

        expect(response).to redirect_to([:admin, ProductType.last])
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved product_type as @product_type' do
        # Trigger the behavior that occurs when invalid params are submitted
        expect_any_instance_of(ProductType).to receive(:save).and_return(false)
        post :create, params: { product_type: { 'name' => 'invalid value' } }

        expect(assigns(:product_type)).to be_a_new(ProductType)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        expect_any_instance_of(ProductType).to receive(:save).and_return(false)
        post :create, params: { product_type: { 'name' => 'invalid value' } }

        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested product_type' do
        product_type = ProductType.create! valid_attributes
        # Assuming there are no other product_types in the database, this
        # specifies that the ProductType created on the previous line
        # receives the :update message with whatever params are
        # submitted in the request.
        put :update, params: { id: product_type.to_param, product_type: { 'name' => 'Fake' } }

        expect(assigns(:product_type).name).to eq('Fake')
      end

      it 'assigns the requested product_type as @product_type' do
        product_type = ProductType.create! valid_attributes
        put :update, params: { id: product_type.to_param, product_type: valid_attributes }

        expect(assigns(:product_type)).to eq(product_type)
      end

      it 'redirects to the product_type' do
        product_type = ProductType.create! valid_attributes
        put :update, params: { id: product_type.to_param, product_type: valid_attributes }

        expect(response).to redirect_to([:admin, product_type])
      end
    end

    describe 'with invalid params' do
      it 'assigns the product_type as @product_type' do
        product_type = ProductType.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        expect_any_instance_of(ProductType).to receive(:save).and_return(false)
        put :update, params: { id: product_type.to_param, product_type: { 'name' => 'invalid value' } }

        expect(assigns(:product_type)).to eq(product_type)
      end

      it "re-renders the 'edit' template" do
        product_type = ProductType.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        expect_any_instance_of(ProductType).to receive(:save).and_return(false)
        put :update, params: { id: product_type.to_param, product_type: { 'name' => 'invalid value' } }

        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested product_type' do
      product_type = ProductType.create! valid_attributes
      expect {
        delete :destroy, params: { id: product_type.to_param }
      }.to change(ProductType, :count).by(-1)
    end

    it 'redirects to the product_types list' do
      product_type = ProductType.create! valid_attributes
      delete :destroy, params: { id: product_type.to_param }
      expect(response).to redirect_to(admin_product_types_url)
    end
  end
end
