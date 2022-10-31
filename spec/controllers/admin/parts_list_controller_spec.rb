require 'spec_helper'

describe Admin::PartsListsController do
  before do
    @radmin ||= FactoryGirl.create(:radmin)
  end

  before(:each) do |example|
    unless example.metadata[:skip_before]
      sign_in @radmin
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # PartsList. As you add validations to PartsList, be sure to adjust the attributes here as well.
  let(:valid_attributes) {
    {
        name: 'fake',
        product_id: 2,
        bricklink_xml: '<XML>fake</XML>',
        original_filename: 'fake.xml'
    }
  }

  let(:invalid_attributes) {
    {
      name: nil,
      product_id: nil,
      bricklink_xml: '',
      original_filename: nil
    }
  }

  describe "GET #index" do
    it "assigns all parts_lists as @parts_lists" do
      parts_list = PartsList.create! valid_attributes
      get :index

      expect(assigns(:parts_lists)).to eq([parts_list])
    end
  end

  describe "GET #show" do
    it "assigns the requested parts_list as @parts_list" do
      parts_list = PartsList.create! valid_attributes
      get :show, id: parts_list.to_param

      expect(assigns(:parts_list)).to eq(parts_list)
    end
  end

  describe "GET #new" do
    it "assigns a new parts_list as @parts_list" do
      get :new

      expect(assigns(:parts_list)).to be_a_new(PartsList)
    end
  end

  describe "GET #edit" do
    it "assigns the requested parts_list as @parts_list" do
      parts_list = PartsList.create! valid_attributes
      get :edit, id: parts_list.to_param

      expect(assigns(:parts_list)).to eq(parts_list)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new PartsList" do
        allow_any_instance_of(BricklinkXmlParser).to receive(:parse).and_return({})
        expect {
          post :create, parts_list: valid_attributes
        }.to change(PartsList, :count).by(1)
      end

      it "assigns a newly created parts_list as @parts_list" do
        allow_any_instance_of(BricklinkXmlParser).to receive(:parse).and_return({})
        post :create, parts_list: valid_attributes

        expect(assigns(:parts_list)).to be_a(PartsList)
        expect(assigns(:parts_list)).to be_persisted
      end

      it "redirects to the created parts_list" do
        allow_any_instance_of(BricklinkXmlParser).to receive(:parse).and_return({})
        post :create, parts_list: valid_attributes

        expect(response).to redirect_to([:admin, PartsList.last])
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved parts_list as @parts_list" do
        post :create, parts_list: invalid_attributes

        expect(assigns(:parts_list)).to be_a_new(PartsList)
      end

      it "re-renders the 'new' template" do
        post :create, parts_list: invalid_attributes

        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            name: 'not fake',
        }
      }

      it "updates the requested parts_list" do
        parts_list = PartsList.create! valid_attributes
        put :update, id: parts_list.to_param, parts_list: new_attributes
        parts_list.reload

        expect(assigns(:parts_list)[:name]).to eq('not fake')
      end

      it "assigns the requested parts_list as @parts_list" do
        parts_list = PartsList.create! valid_attributes
        put :update, id: parts_list.to_param, parts_list: valid_attributes

        expect(assigns(:parts_list)).to eq(parts_list)
      end

      it "redirects to the parts_list" do
        parts_list = PartsList.create! valid_attributes
        put :update, id: parts_list.to_param, parts_list: valid_attributes

        expect(response).to redirect_to([:admin, parts_list])
      end
    end

    context "with invalid params" do
      it "assigns the parts_list as @parts_list" do
        parts_list = PartsList.create! valid_attributes
        put :update, id: parts_list.to_param, parts_list: invalid_attributes

        expect(assigns(:parts_list)).to eq(parts_list)
      end

      it "re-renders the 'edit' template" do
        parts_list = PartsList.create! valid_attributes
        put :update, id: parts_list.to_param, parts_list: invalid_attributes

        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested parts_list" do
      parts_list = PartsList.create! valid_attributes
      expect {
        delete :destroy, id: parts_list.to_param
      }.to change(PartsList, :count).by(-1)
    end

    it "redirects to the parts_lists list" do
      parts_list = PartsList.create! valid_attributes
      delete :destroy, id: parts_list.to_param

      expect(response).to redirect_to(admin_parts_lists_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page", :skip_before do
      get :index

      expect(response).to redirect_to('/radmins/sign_in')
    end
  end
end
