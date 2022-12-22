require 'spec_helper'

describe Admin::AdvertisingCampaignsController do
  before do
    @radmin ||= FactoryGirl.create(:radmin)
    @partner = FactoryGirl.create(:partner, id: 1)
  end

  before(:each) do
    sign_in @radmin
  end

  # This should return the minimal set of attributes required to create a valid
  # AdvertisingCampaign. As you add validations to AdvertisingCampaign, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        partner_id: 1,
        description: 'Description',
        reference_code: '123456789A'
    }
  }

  let(:invalid_attributes) {
    {
        description: 'Description',
        reference_code: '1234'
    }
  }

  describe "GET #index" do
    it "assigns all advertising_campaigns as @advertising_campaigns" do
      advertising_campaign = AdvertisingCampaign.create! valid_attributes
      get :index

      expect(assigns(:advertising_campaigns)).to eq([advertising_campaign])
    end
  end

  describe "GET #show" do
    it "assigns the requested advertising_campaign as @advertising_campaign" do
      advertising_campaign = AdvertisingCampaign.create! valid_attributes
      get :show, params: { id: advertising_campaign.to_param }

      expect(assigns(:advertising_campaign)).to eq(advertising_campaign)
    end
  end

  describe "GET #new" do
    it "assigns a new advertising_campaign as @advertising_campaign" do
      get :new

      expect(assigns(:advertising_campaign)).to be_a_new(AdvertisingCampaign)
    end
  end

  describe "GET #edit" do
    it "assigns the requested advertising_campaign as @advertising_campaign" do
      advertising_campaign = AdvertisingCampaign.create! valid_attributes
      get :edit, params: { id: advertising_campaign.to_param }

      expect(assigns(:advertising_campaign)).to eq(advertising_campaign)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new AdvertisingCampaign" do
        expect {
          post :create, params: { advertising_campaign: valid_attributes }
        }.to change(AdvertisingCampaign, :count).by(1)
      end

      it "assigns a newly created advertising_campaign as @advertising_campaign" do
        post :create, params: { advertising_campaign: valid_attributes }

        expect(assigns(:advertising_campaign)).to be_a(AdvertisingCampaign)
        expect(assigns(:advertising_campaign)).to be_persisted
      end

      it "redirects to the created advertising_campaign" do
        post :create, params: { advertising_campaign: valid_attributes }

        expect(response).to redirect_to([:admin, AdvertisingCampaign.last])
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved advertising_campaign as @advertising_campaign" do
        post :create, params: { advertising_campaign: invalid_attributes }

        expect(assigns(:advertising_campaign)).to be_a_new(AdvertisingCampaign)
      end

      it "re-renders the 'new' template" do
        post :create, params: { advertising_campaign: invalid_attributes }

        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            partner_id: 2,
            description: 'New Description',
            reference_code: '123456789B'
        }
      }

      it "updates the requested advertising_campaign" do
        advertising_campaign = AdvertisingCampaign.create! valid_attributes
        put :update, params: { id: advertising_campaign.to_param, advertising_campaign: new_attributes }
        advertising_campaign.reload

        expect(assigns(:advertising_campaign)[:reference_code]).to eq('123456789B')
        expect(assigns(:advertising_campaign)[:description]).to eq('New Description')
        expect(assigns(:advertising_campaign)[:partner_id]).to eq(2)
      end

      it "assigns the requested advertising_campaign as @advertising_campaign" do
        advertising_campaign = AdvertisingCampaign.create! valid_attributes
        put :update, params: { id: advertising_campaign.to_param, advertising_campaign: valid_attributes }

        expect(assigns(:advertising_campaign)).to eq(advertising_campaign)
      end

      it "redirects to the advertising_campaign" do
        advertising_campaign = AdvertisingCampaign.create! valid_attributes
        put :update, params: { id: advertising_campaign.to_param, advertising_campaign: valid_attributes }

        expect(response).to redirect_to([:admin, advertising_campaign])
      end
    end

    context "with invalid params" do
      it "assigns the advertising_campaign as @advertising_campaign" do
        advertising_campaign = AdvertisingCampaign.create! valid_attributes
        put :update, params: { id: advertising_campaign.to_param, advertising_campaign: invalid_attributes }

        expect(assigns(:advertising_campaign)).to eq(advertising_campaign)
      end

      it "re-renders the 'edit' template" do
        advertising_campaign = AdvertisingCampaign.create! valid_attributes
        put :update, params: { id: advertising_campaign.to_param, advertising_campaign: invalid_attributes }

        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested advertising_campaign" do
      advertising_campaign = AdvertisingCampaign.create! valid_attributes
      expect {
        delete :destroy, params: { id: advertising_campaign.to_param }
      }.to change(AdvertisingCampaign, :count).by(-1)
    end

    it "redirects to the advertising_campaigns list" do
      advertising_campaign = AdvertisingCampaign.create! valid_attributes
      delete :destroy, params: { id: advertising_campaign.to_param }

      expect(response).to redirect_to(admin_advertising_campaigns_url)
    end
  end

end
