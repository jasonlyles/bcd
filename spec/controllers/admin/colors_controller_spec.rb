require 'spec_helper'

describe Admin::ColorsController do
  before do
    @radmin ||= FactoryGirl.create(:radmin)
  end

  before(:each) do |example|
    unless example.metadata[:skip_before]
      sign_in @radmin
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # Color. As you add validations to Color, be sure to adjust the attributes here as well.
  let(:valid_attributes) {
    {
        name: 'Blue'
    }
  }

  let(:invalid_attributes) {
    {
      name: nil
    }
  }

  describe "GET #index" do
    it "assigns all colors as @colors" do
      color = Color.create! valid_attributes
      get :index

      expect(assigns(:colors)).to eq([color])
    end
  end

  describe "GET #show" do
    it "assigns the requested color as @color" do
      color = Color.create! valid_attributes
      get :show, params: { id: color.to_param }

      expect(assigns(:color)).to eq(color)
    end
  end

  describe "GET #new" do
    it "assigns a new color as @color" do
      get :new

      expect(assigns(:color)).to be_a_new(Color)
    end
  end

  describe "GET #edit" do
    it "assigns the requested color as @color" do
      color = Color.create! valid_attributes
      get :edit, params: { id: color.to_param }

      expect(assigns(:color)).to eq(color)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Color" do
        expect {
          post :create, params: { color: valid_attributes }
        }.to change(Color, :count).by(1)
      end

      it "assigns a newly created color as @color" do
        post :create, params: { color: valid_attributes }

        expect(assigns(:color)).to be_a(Color)
        expect(assigns(:color)).to be_persisted
      end

      it "redirects to the created color" do
        post :create, params: { color: valid_attributes }

        expect(response).to redirect_to([:admin, Color.last])
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved color as @color" do
        post :create, params: { color: invalid_attributes }

        expect(assigns(:color)).to be_a_new(Color)
      end

      it "re-renders the 'new' template" do
        post :create, params: { color: invalid_attributes }

        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            name: 'Black',
        }
      }

      it "updates the requested color" do
        color = Color.create! valid_attributes
        put :update, params: { id: color.to_param, color: new_attributes }
        color.reload

        expect(assigns(:color)[:name]).to eq('Black')
      end

      it "assigns the requested color as @color" do
        color = Color.create! valid_attributes
        put :update, params: { id: color.to_param, color: valid_attributes }

        expect(assigns(:color)).to eq(color)
      end

      it "redirects to the color" do
        color = Color.create! valid_attributes
        put :update, params: { id: color.to_param, color: valid_attributes }

        expect(response).to redirect_to([:admin, color])
      end
    end

    context "with invalid params" do
      it "assigns the color as @color" do
        color = Color.create! valid_attributes
        put :update, params: { id: color.to_param, color: invalid_attributes }

        expect(assigns(:color)).to eq(color)
      end

      it "re-renders the 'edit' template" do
        color = Color.create! valid_attributes
        put :update, params: { id: color.to_param, color: invalid_attributes }

        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested color" do
      color = Color.create! valid_attributes
      expect {
        delete :destroy, params: { id: color.to_param }
      }.to change(Color, :count).by(-1)
    end

    it "redirects to the colors list" do
      color = Color.create! valid_attributes
      delete :destroy, params: { id: color.to_param }

      expect(response).to redirect_to(admin_colors_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page", :skip_before do
      get :index

      expect(response).to redirect_to('/radmins/sign_in')
    end
  end
end
