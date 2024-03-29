require 'spec_helper'

describe Admin::CategoriesController do

  before do
    @radmin ||= FactoryBot.create(:radmin)
  end

  before(:each) do |example|
    unless example.metadata[:skip_before]
      sign_in @radmin
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # Category. As you add validations to Category, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        name: 'Category 1',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis vitae magna eget massa nunc.'
    }
  }

  let(:invalid_attributes) {
    {
        description: 'Too short description',
    }
  }

  describe "GET #index" do
    it "assigns all categories as @categories" do
      category = Category.create! valid_attributes
      get :index

      expect(assigns(:categories)).to eq([category])
    end
  end

  describe "GET #show" do
    it "assigns the requested category as @category" do
      category = Category.create! valid_attributes
      get :show, params: { id: category.to_param }

      expect(assigns(:category)).to eq(category)
    end
  end

  describe "GET #new" do
    it "assigns a new category as @category" do
      get :new

      expect(assigns(:category)).to be_a_new(Category)
    end
  end

  describe "GET #edit" do
    it "assigns the requested category as @category" do
      category = Category.create! valid_attributes
      get :edit, params: { id: category.to_param }

      expect(assigns(:category)).to eq(category)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Category" do
        expect {
          post :create, params: { category: valid_attributes }
        }.to change(Category, :count).by(1)
      end

      it "assigns a newly created category as @category" do
        post :create, params: { category: valid_attributes }

        expect(assigns(:category)).to be_a(Category)
        expect(assigns(:category)).to be_persisted
      end

      it "redirects to the created category" do
        post :create, params: { category: valid_attributes }

        expect(response).to redirect_to([:admin, Category.last])
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved category as @category" do
        post :create, params: { category: invalid_attributes }

        expect(assigns(:category)).to be_a_new(Category)
      end

      it "re-renders the 'new' template" do
        post :create, params: { category: invalid_attributes }

        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            name: 'Category 2',
            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis vitae magna eget massa nunc. 2'
        }
      }

      it "updates the requested category" do
        category = Category.create! valid_attributes
        put :update, params: { id: category.to_param, category: new_attributes }
        category.reload

        expect(assigns(:category)[:name]).to eq('Category 2')
        expect(assigns(:category)[:description]).to eq('Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sagittis vitae magna eget massa nunc. 2')
      end

      it "assigns the requested category as @category" do
        category = Category.create! valid_attributes
        put :update, params: { id: category.to_param, category: valid_attributes }

        expect(assigns(:category)).to eq(category)
      end

      it "redirects to the category" do
        category = Category.create! valid_attributes
        put :update, params: { id: category.to_param, category: valid_attributes }

        expect(response).to redirect_to([:admin, category])
      end
    end

    context "with invalid params" do
      it "assigns the category as @category" do
        category = Category.create! valid_attributes
        put :update, params: { id: category.to_param, category: invalid_attributes }

        expect(assigns(:category)).to eq(category)
      end

      it "re-renders the 'edit' template" do
        category = Category.create! valid_attributes
        put :update, params: { id: category.to_param, category: invalid_attributes }

        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested category" do
      category = Category.create! valid_attributes
      expect {
        delete :destroy, params: { id: category.to_param }
      }.to change(Category, :count).by(-1)
    end

    it "redirects to the categories list" do
      category = Category.create! valid_attributes
      delete :destroy, params: { id: category.to_param }

      expect(response).to redirect_to(admin_categories_url)
    end

    it "should not destroy a category that has subcategories" do
      @category = FactoryBot.create(:category_with_subcategories)
      delete :destroy, params: { id: @category.id }

      expect(response).to redirect_to(admin_categories_url)
      expect(flash[:alert]).to eq("You can't delete this category while it has subcategories. Delete or reassign the subcategories and try again.")
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page", :skip_before do
      get :index

      expect(response).to redirect_to('/radmins/sign_in')
    end
  end

  describe "requesting a categories subcategories" do
    it "should fetch some subcategories" do
      @category = FactoryBot.create(:category_with_subcategories)
      get :subcategories, params: { id: 1 }, format: :json

      expect(JSON.parse(response.body)[0]['description']).to eq('City Vehicles are awesome')
    end
  end

end
