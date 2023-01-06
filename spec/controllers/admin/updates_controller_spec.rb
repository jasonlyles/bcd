require 'spec_helper'

describe Admin::UpdatesController do

  before do
    @radmin ||= FactoryBot.create(:radmin)
  end

  before(:each) do |example|
    unless example.metadata[:skip_before]
      sign_in @radmin
    end
  end

  # This should return the minimal set of attributes required to create a valid
  # Update. As you add validations to Update, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        title: 'Update 1'
    }
  }

  let(:invalid_attributes) {
    {
        fake: nil
    }
  }

  describe "GET #index" do
    it "assigns all updates as @updates" do
      update = Update.create! valid_attributes
      get :index

      expect(assigns(:updates)).to eq([update])
    end
  end

  describe "GET #show" do
    it "assigns the requested update as @update" do
      update = Update.create! valid_attributes
      get :show, params: { id: update.to_param }

      expect(assigns(:update)).to eq(update)
    end
  end

  describe "GET #new" do
    it "assigns a new update as @update" do
      get :new

      expect(assigns(:update)).to be_a_new(Update)
    end
  end

  describe "GET #edit" do
    it "assigns the requested update as @update" do
      update = Update.create! valid_attributes
      get :edit, params: { id: update.to_param }

      expect(assigns(:update)).to eq(update)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Update" do
        expect {
          post :create, params: { update: valid_attributes }
        }.to change(Update, :count).by(1)
      end

      it "assigns a newly created update as @update" do
        post :create, params: { update: valid_attributes }

        expect(assigns(:update)).to be_a(Update)
        expect(assigns(:update)).to be_persisted
      end

      it "redirects to the created update" do
        post :create, params: { update: valid_attributes }

        expect(response).to redirect_to([:admin, Update.last])
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved update as @update" do
        post :create, params: { update: invalid_attributes }

        expect(assigns(:update)).to be_a_new(Update)
      end

      it "re-renders the 'new' template" do
        post :create, params: { update: invalid_attributes }

        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            title: 'Update 2'
        }
      }

      it "updates the requested update" do
        update = Update.create! valid_attributes
        put :update, params: { id: update.to_param, update: new_attributes }
        update.reload

        expect(assigns(:update)[:title]).to eq('Update 2')
      end

      it "assigns the requested update as @update" do
        update = Update.create! valid_attributes
        put :update, params: { id: update.to_param, update: valid_attributes }

        expect(assigns(:update)).to eq(update)
      end

      it "redirects to the update" do
        update = Update.create! valid_attributes
        put :update, params: { id: update.to_param, update: valid_attributes }

        expect(response).to redirect_to([:admin, update])
      end
    end

    context "with invalid params" do
      it "assigns the update as @update" do
        update = Update.create! valid_attributes
        put :update, params: { id: update.to_param, update: invalid_attributes }

        expect(assigns(:update)).to eq(update)
      end

      it "re-renders the 'edit' template" do
        update = Update.create! valid_attributes
        put :update, params: { id: update.to_param, update: { title: nil } }

        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested update" do
      update = Update.create! valid_attributes
      expect {
        delete :destroy, params: { id: update.to_param }
      }.to change(Update, :count).by(-1)
    end

    it "redirects to the updates list" do
      update = Update.create! valid_attributes
      delete :destroy, params: { id: update.to_param }

      expect(response).to redirect_to(admin_updates_url)
    end
  end

  describe "an invalid radmin login" do
    it "should redirect to radmin login page", :skip_before do
      get :index
      expect(response).to redirect_to('/radmins/sign_in')
    end
  end
end
