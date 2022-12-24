require 'spec_helper'

describe Admin::PartnersController do

  before do
    @radmin ||= FactoryBot.create(:radmin)
  end

  before(:each) do
    sign_in @radmin
  end

  # This should return the minimal set of attributes required to create a valid
  # Partner. As you add validations to Partner, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        name: 'Bob',
        url: 'http://www.bob.com'
    }
  }

  let(:invalid_attributes) {
    {
        name: nil,
        url: nil
    }
  }

  describe "GET #index" do
    it "assigns all partners as @partners" do
      partner = Partner.create! valid_attributes
      get :index

      expect(assigns(:partners)).to eq([partner])
    end
  end

  describe "GET #show" do
    it "assigns the requested partner as @partner" do
      partner = Partner.create! valid_attributes
      get :show, params: { id: partner.to_param }

      expect(assigns(:partner)).to eq(partner)
    end
  end

  describe "GET #new" do
    it "assigns a new partner as @partner" do
      get :new

      expect(assigns(:partner)).to be_a_new(Partner)
    end
  end

  describe "GET #edit" do
    it "assigns the requested partner as @partner" do
      partner = Partner.create! valid_attributes
      get :edit, params: { id: partner.to_param }

      expect(assigns(:partner)).to eq(partner)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Partner" do
        expect {
          post :create, params: { partner: valid_attributes }
        }.to change(Partner, :count).by(1)
      end

      it "assigns a newly created partner as @partner" do
        post :create, params: { partner: valid_attributes }

        expect(assigns(:partner)).to be_a(Partner)
        expect(assigns(:partner)).to be_persisted
      end

      it "redirects to the created partner" do
        post :create, params: { partner: valid_attributes }

        expect(response).to redirect_to([:admin, Partner.last])
      end
    end

    context "with invalid params" do
# I don't presently have any validations on image, since everything I would set is optional
=begin
      it "assigns a newly created but unsaved partner as @partner" do
        post :create, partner: invalid_attributes

        expect(assigns(:partner)).to be_a_new(Partner)
      end
=end
# I don't presently have any validations on image, since everything I would set is optional
=begin
      it "re-renders the 'new' template" do
        post :create, partner: invalid_attributes

        expect(response).to render_template("new")
      end
=end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
            name: 'Bob 2',
            url: 'http://www.google.com'
        }
      }

      it "updates the requested partner" do
        partner = Partner.create! valid_attributes
        put :update, params: { id: partner.to_param, partner: new_attributes }
        partner.reload

        expect(assigns(:partner)[:name]).to eq('Bob 2')
        expect(assigns(:partner)[:url]).to eq('http://www.google.com')
      end

      it "assigns the requested partner as @partner" do
        partner = Partner.create! valid_attributes
        put :update, params: { id: partner.to_param, partner: valid_attributes }

        expect(assigns(:partner)).to eq(partner)
      end

      it "redirects to the partner" do
        partner = Partner.create! valid_attributes
        put :update, params: { id: partner.to_param, partner: valid_attributes }

        expect(response).to redirect_to([:admin, partner])
      end
    end

    context "with invalid params" do
      it "assigns the partner as @partner" do
        partner = Partner.create! valid_attributes
        put :update, params: { id: partner.to_param, partner: invalid_attributes }

        expect(assigns(:partner)).to eq(partner)
      end
# I don't presently have any validations on image, since everything I would set is optional
=begin
      it "re-renders the 'edit' template" do
        partner = Partner.create! valid_attributes
        put :update, id: partner.to_param, partner: invalid_attributes

        expect(response).to render_template("edit")
      end
=end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested partner" do
      partner = Partner.create! valid_attributes
      expect {
        delete :destroy, params: { id: partner.to_param }
      }.to change(Partner, :count).by(-1)
    end

    it "redirects to the partners list" do
      partner = Partner.create! valid_attributes
      delete :destroy, params: { id: partner.to_param }

      expect(response).to redirect_to(admin_partners_url)
    end

    it "should redirect to the partners list if partner can't be deleted due to an advertising campaign with that partner that went live" do
      expect(Partner).to receive(:find).with("1") {Partner.new}
      expect_any_instance_of(Partner).to receive(:destroy).and_return(nil)
      delete :destroy, params: { id: '1' }

      expect(flash[:alert]).to eq("Sorry. You can't delete a partner that has advertising campaigns that have been used.")
      expect(response).to redirect_to(admin_partners_url)
    end
  end

end
