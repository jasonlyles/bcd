require 'spec_helper'

describe Admin::EmailCampaignsController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
  end

  before(:each) do |example|
    sign_in @radmin unless example.metadata[:skip_before]
  end

  # This should return the minimal set of attributes required to create a valid
  # EmailCampaign. As you add validations to EmailCampaign, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      description: 'Description 1',
      subject: 'Subject 1'
    }
  }

  let(:invalid_attributes) {
    {
      description: nil,
      subject: nil
    }
  }

  describe 'GET #index' do
    it 'assigns all email_campaigns as @email_campaigns' do
      email_campaign = EmailCampaign.create! valid_attributes
      get :index

      expect(assigns(:email_campaigns)).to eq([email_campaign])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested email_campaign as @email_campaign' do
      email_campaign = EmailCampaign.create! valid_attributes
      get :show, params: { id: email_campaign.to_param }

      expect(assigns(:email_campaign)).to eq(email_campaign)
    end
  end

  describe 'GET #new' do
    it 'assigns a new email_campaign as @email_campaign' do
      get :new

      expect(assigns(:email_campaign)).to be_a_new(EmailCampaign)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested email_campaign as @email_campaign' do
      email_campaign = EmailCampaign.create! valid_attributes
      get :edit, params: { id: email_campaign.to_param }

      expect(assigns(:email_campaign)).to eq(email_campaign)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new EmailCampaign' do
        expect {
          post :create, params: { email_campaign: valid_attributes }
        }.to change(EmailCampaign, :count).by(1)
      end

      it 'assigns a newly created email_campaign as @email_campaign' do
        post :create, params: { email_campaign: valid_attributes }

        expect(assigns(:email_campaign)).to be_a(EmailCampaign)
        expect(assigns(:email_campaign)).to be_persisted
      end

      it 'redirects to the created email_campaign' do
        post :create, params: { email_campaign: valid_attributes }

        expect(response).to redirect_to([:admin, EmailCampaign.last])
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved email_campaign as @email_campaign' do
        post :create, params: { email_campaign: invalid_attributes }

        expect(assigns(:email_campaign)).to be_a_new(EmailCampaign)
      end

      it "re-renders the 'new' template" do
        post :create, params: { email_campaign: invalid_attributes }

        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {
          description: 'Description 2',
          subject: 'Subject 2'
        }
      }

      it 'updates the requested email_campaign' do
        email_campaign = EmailCampaign.create! valid_attributes
        put :update, params: { id: email_campaign.to_param, email_campaign: new_attributes }
        email_campaign.reload

        expect(assigns(:email_campaign)[:description]).to eq('Description 2')
        expect(assigns(:email_campaign)[:subject]).to eq('Subject 2')
      end

      it 'assigns the requested email_campaign as @email_campaign' do
        email_campaign = EmailCampaign.create! valid_attributes
        put :update, params: { id: email_campaign.to_param, email_campaign: valid_attributes }

        expect(assigns(:email_campaign)).to eq(email_campaign)
      end

      it 'redirects to the email_campaign' do
        email_campaign = EmailCampaign.create! valid_attributes
        put :update, params: { id: email_campaign.to_param, email_campaign: valid_attributes }

        expect(response).to redirect_to([:admin, email_campaign])
      end
    end

    context 'with invalid params' do
      it 'assigns the email_campaign as @email_campaign' do
        email_campaign = EmailCampaign.create! valid_attributes
        put :update, params: { id: email_campaign.to_param, email_campaign: invalid_attributes }

        expect(assigns(:email_campaign)).to eq(email_campaign)
      end

      it "re-renders the 'edit' template" do
        email_campaign = EmailCampaign.create! valid_attributes
        put :update, params: { id: email_campaign.to_param, email_campaign: invalid_attributes }

        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested email_campaign' do
      email_campaign = EmailCampaign.create! valid_attributes
      expect {
        delete :destroy, params: { id: email_campaign.to_param }
      }.to change(EmailCampaign, :count).by(-1)
    end

    it 'redirects to the email_campaigns list' do
      email_campaign = EmailCampaign.create! valid_attributes
      delete :destroy, params: { id: email_campaign.to_param }

      expect(response).to redirect_to(admin_email_campaigns_url)
    end
  end

  describe 'an invalid radmin login' do
    it 'should redirect to radmin login page', :skip_before do
      get :index

      expect(response).to redirect_to('/radmins/sign_in')
    end
  end

  describe 'send_marketing_emails' do
    it 'should queue up a job if all is well' do
      @email_campaign = FactoryBot.create(:email_campaign)
      expect(NewMarketingNotificationJob).to receive(:perform_async)
      patch :send_marketing_emails, params: { email_campaign: { 'id' => 1 } }

      expect(flash[:notice]).to eq('Sending marketing emails')
      expect(response).to redirect_to '/admin/email_campaigns'
    end
  end

  describe 'send_marketing_email_preview' do
    it 'should queue up a job if all is well' do
      @email_campaign = FactoryBot.create(:email_campaign)
      expect(NewMarketingNotificationJob).to receive(:perform_async)
      patch :send_marketing_email_preview, params: { email_campaign: { 'id' => 1 } }

      expect(flash[:notice]).to eq('Sending marketing email preview')
      expect(response).to redirect_to "/admin/email_campaigns/#{@email_campaign.id}"
    end
  end
end
