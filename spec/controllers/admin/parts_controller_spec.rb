require 'spec_helper'

describe Admin::PartsController do
  before do
    @radmin ||= FactoryGirl.create(:radmin)
  end

  before(:each) do |example|
    unless example.metadata[:skip_before]
      sign_in @radmin
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # Part. As you add validations to Part, be sure to adjust the attributes here as well.
  let(:valid_attributes) {
    {
        name: '1 x 1 Brick'
    }
  }

  let(:invalid_attributes) {
    {
      name: nil
    }
  }

  describe "GET #index" do
    it "assigns all parts as @parts" do
      part = Part.create! valid_attributes
      get :index

      expect(assigns(:parts)).to eq([part])
    end
  end

  describe "GET #show" do
    it "assigns the requested part as @part" do
      part = Part.create! valid_attributes
      get :show, id: part.to_param

      expect(assigns(:part)).to eq(part)
    end
  end

  describe "GET #new" do
    it "assigns a new part as @part" do
      get :new

      expect(assigns(:part)).to be_a_new(Part)
    end
  end

  describe "GET #edit" do
    it "assigns the requested part as @part" do
      part = Part.create! valid_attributes
      get :edit, id: part.to_param

      expect(assigns(:part)).to eq(part)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Part" do
        expect {
          post :create, part: valid_attributes
        }.to change(Part, :count).by(1)
      end

      it "assigns a newly created part as @part" do
        post :create, part: valid_attributes

        expect(assigns(:part)).to be_a(Part)
        expect(assigns(:part)).to be_persisted
      end

      it "redirects to the created part" do
        post :create, part: valid_attributes

        expect(response).to redirect_to([:admin, Part.last])
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved part as @part" do
        post :create, part: invalid_attributes

        expect(assigns(:part)).to be_a_new(Part)
      end

      it "re-renders the 'new' template" do
        post :create, part: invalid_attributes

        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            name: '1 x 2 Brick',
        }
      }

      it "updates the requested part" do
        part = Part.create! valid_attributes
        put :update, id: part.to_param, part: new_attributes
        part.reload

        expect(assigns(:part)[:name]).to eq('1 x 2 Brick')
      end

      it "assigns the requested part as @part" do
        part = Part.create! valid_attributes
        put :update, id: part.to_param, part: valid_attributes

        expect(assigns(:part)).to eq(part)
      end

      it "redirects to the part" do
        part = Part.create! valid_attributes
        put :update, id: part.to_param, part: valid_attributes

        expect(response).to redirect_to([:admin, part])
      end
    end

    context "with invalid params" do
      it "assigns the part as @part" do
        part = Part.create! valid_attributes
        put :update, id: part.to_param, part: invalid_attributes

        expect(assigns(:part)).to eq(part)
      end

      it "re-renders the 'edit' template" do
        part = Part.create! valid_attributes
        put :update, id: part.to_param, part: invalid_attributes

        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested part" do
      part = Part.create! valid_attributes
      expect {
        delete :destroy, id: part.to_param
      }.to change(Part, :count).by(-1)
    end

    it "redirects to the parts list" do
      part = Part.create! valid_attributes
      delete :destroy, id: part.to_param

      expect(response).to redirect_to(admin_parts_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page", :skip_before do
      get :index

      expect(response).to redirect_to('/radmins/sign_in')
    end
  end
end
