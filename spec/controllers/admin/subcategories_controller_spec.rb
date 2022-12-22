require 'spec_helper'

describe Admin::SubcategoriesController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
  end

  before(:each) do |example|
    unless example.metadata[:skip_before]
      sign_in @radmin
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # Subcategory. As you add validations to Subcategory, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        name: 'Vehicles',
        code: 'CV',
        category_id: @category.id
    }
  }

  let(:invalid_attributes) {
    {
        name: nil,
        code: nil
    }
  }

  describe "GET #index" do
    it "assigns all subcategories as @subcategories" do
      subcategory = Subcategory.create! valid_attributes
      get :index

      expect(assigns(:subcategories)).to eq([subcategory])
    end
  end

  describe "GET #show" do
    it "assigns the requested subcategory as @subcategory" do
      subcategory = Subcategory.create! valid_attributes
      get :show, params: { id: subcategory.to_param }

      expect(assigns(:subcategory)).to eq(subcategory)
    end
  end

  describe "GET #new" do
    it "assigns a new subcategory as @subcategory" do
      get :new

      expect(assigns(:subcategory)).to be_a_new(Subcategory)
    end
  end

  describe "GET #edit" do
    it "assigns the requested subcategory as @subcategory" do
      subcategory = Subcategory.create! valid_attributes
      get :edit, params: { id: subcategory.to_param }

      expect(assigns(:subcategory)).to eq(subcategory)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Subcategory" do
        expect {
          post :create, params: { subcategory: valid_attributes }
        }.to change(Subcategory, :count).by(1)
      end

      it "assigns a newly created subcategory as @subcategory" do
        post :create, params: { subcategory: valid_attributes }

        expect(assigns(:subcategory)).to be_a(Subcategory)
        expect(assigns(:subcategory)).to be_persisted
      end

      it "redirects to the created subcategory" do
        post :create, params: { subcategory: valid_attributes }

        expect(response).to redirect_to([:admin, Subcategory.last])
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved subcategory as @subcategory" do
        post :create, params: { subcategory: invalid_attributes }

        expect(assigns(:subcategory)).to be_a_new(Subcategory)
      end

      it "re-renders the 'new' template" do
        post :create, params: { subcategory: invalid_attributes }

        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            name: 'Buildings',
            code: 'CB'
        }
      }

      it "updates the requested subcategory" do
        subcategory = Subcategory.create! valid_attributes
        put :update, params: { id: subcategory.to_param, subcategory: new_attributes }
        subcategory.reload

        expect(assigns(:subcategory)[:name]).to eq('Buildings')
        expect(assigns(:subcategory)[:code]).to eq('CB')
      end

      it "assigns the requested subcategory as @subcategory" do
        subcategory = Subcategory.create! valid_attributes
        put :update, params: { id: subcategory.to_param, subcategory: valid_attributes }

        expect(assigns(:subcategory)).to eq(subcategory)
      end

      it "redirects to the subcategory" do
        subcategory = Subcategory.create! valid_attributes
        put :update, params: { id: subcategory.to_param, subcategory: valid_attributes }

        expect(response).to redirect_to([:admin, subcategory])
      end
    end

    context "with invalid params" do
      it "assigns the subcategory as @subcategory" do
        subcategory = Subcategory.create! valid_attributes
        put :update, params: { id: subcategory.to_param, subcategory: invalid_attributes }

        expect(assigns(:subcategory)).to eq(subcategory)
      end

      it "re-renders the 'edit' template" do
        subcategory = Subcategory.create! valid_attributes
        put :update, params: { id: subcategory.to_param, subcategory: invalid_attributes }

        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested subcategory" do
      subcategory = Subcategory.create! valid_attributes
      expect {
        delete :destroy, params: { id: subcategory.to_param }
      }.to change(Subcategory, :count).by(-1)
    end

    it "redirects to the subcategories list" do
      subcategory = Subcategory.create! valid_attributes
      delete :destroy, params: { id: subcategory.to_param }

      expect(response).to redirect_to(admin_subcategories_url)
    end

    it "should not destroy a subcategory that has products" do
      @subcat = FactoryGirl.create(:subcategory_with_products)
      sign_in @radmin
      delete :destroy, params: { id: @subcat.id }
      expect(response).to redirect_to(admin_subcategories_url)
      expect(flash[:alert]).to eq("You can't delete this subcategory while it has products. Delete or reassign the products and try again.")
    end
  end

  describe "model_code" do
    it "should get a suggested model_code" do
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      sign_in @radmin
      get :model_code, params: { id: @subcategory.id }, format: :json

      #really I think I need to figure out some way to test that this is getting rendered in json, but I don't know how to test for that yet.
      expect(assigns(:model_code)).to eq("#{@subcategory.code}002")
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page", :skip_before do
      get :index
      expect(response).to redirect_to('/radmins/sign_in')
    end
  end
end
