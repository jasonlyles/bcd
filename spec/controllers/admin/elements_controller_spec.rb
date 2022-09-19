require 'spec_helper'

describe Admin::ElementsController do
  before do
    @radmin ||= FactoryGirl.create(:radmin)
  end

  before(:each) do |example|
    unless example.metadata[:skip_before]
      sign_in @radmin
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # Element. As you add validations to Element, be sure to adjust the attributes here as well.
  let(:valid_attributes) {
    {
        part_id: 1,
        color_id: 2
    }
  }

  let(:invalid_attributes) {
    {
      part_id: nil,
      color_id: nil
    }
  }

  describe "GET #index" do
    it "assigns all elements as @elements" do
      element = Element.create! valid_attributes
      get :index

      expect(assigns(:elements)).to eq([element])
    end
  end

  describe "GET #show" do
    it "assigns the requested element as @element" do
      element = Element.create! valid_attributes
      get :show, id: element.to_param

      expect(assigns(:element)).to eq(element)
    end
  end

  describe "GET #new" do
    it "assigns a new element as @element" do
      get :new

      expect(assigns(:element)).to be_a_new(Element)
    end
  end

  describe "GET #edit" do
    it "assigns the requested element as @element" do
      element = Element.create! valid_attributes
      get :edit, id: element.to_param

      expect(assigns(:element)).to eq(element)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Element" do
        expect {
          post :create, element: valid_attributes
        }.to change(Element, :count).by(1)
      end

      it "assigns a newly created element as @element" do
        post :create, element: valid_attributes

        expect(assigns(:element)).to be_a(Element)
        expect(assigns(:element)).to be_persisted
      end

      it "redirects to the created element" do
        post :create, element: valid_attributes

        expect(response).to redirect_to([:admin, Element.last])
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved element as @element" do
        post :create, element: invalid_attributes

        expect(assigns(:element)).to be_a_new(Element)
      end

      it "re-renders the 'new' template" do
        post :create, element: invalid_attributes

        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            part_id: 2,
        }
      }

      it "updates the requested element" do
        element = Element.create! valid_attributes
        put :update, id: element.to_param, element: new_attributes
        element.reload

        expect(assigns(:element)[:part_id]).to eq(2)
      end

      it "assigns the requested element as @element" do
        element = Element.create! valid_attributes
        put :update, id: element.to_param, element: valid_attributes

        expect(assigns(:element)).to eq(element)
      end

      it "redirects to the element" do
        element = Element.create! valid_attributes
        put :update, id: element.to_param, element: valid_attributes

        expect(response).to redirect_to([:admin, element])
      end
    end

    context "with invalid params" do
      it "assigns the element as @element" do
        element = Element.create! valid_attributes
        put :update, id: element.to_param, element: invalid_attributes

        expect(assigns(:element)).to eq(element)
      end

      it "re-renders the 'edit' template" do
        element = Element.create! valid_attributes
        put :update, id: element.to_param, element: invalid_attributes

        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested element" do
      element = Element.create! valid_attributes
      expect {
        delete :destroy, id: element.to_param
      }.to change(Element, :count).by(-1)
    end

    it "redirects to the elements list" do
      element = Element.create! valid_attributes
      delete :destroy, id: element.to_param

      expect(response).to redirect_to(admin_elements_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page", :skip_before do
      get :index

      expect(response).to redirect_to('/radmins/sign_in')
    end
  end

  describe 'POST find_or_create' do
    context 'where the element already exists' do
      it 'should find the existing element and return it' do
        allow_any_instance_of(ImageUploader).to receive(:present?).and_return(true)
        color = FactoryGirl.create(:color)
        part = FactoryGirl.create(:part, name: 'Brick 1 x 1')
        element = FactoryGirl.create(:element, color_id: color.id, part_id: part.id, image: 'fake.jpg')

        params = {
          part_name: 'Brick 1 x 1',
          color_id: color.id
        }

        expect {
          post :find_or_create, params
        }.not_to change(Element, :count)

        expect(response.status).to eq(200)
      end
    end
  end
end
