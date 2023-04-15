require 'spec_helper'

describe Admin::EtsyController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
    @product = FactoryBot.create(:product_with_associations)
  end

  before(:each) do |example|
    sign_in @radmin unless example.metadata[:skip_before]
  end

  describe 'callback' do
    it 'should store access data' do
      session[:etsy_code_verifier] = 'abc'
      expires_at = Time.now + 1.hour
      allow(Etsy::Api::AccessToken).to receive(:get).and_return({ access_token: 'token1', refresh_token: 'token2', expires_at: })

      get :callback, params: { code: '1234' }

      bot = BackendOauthToken.last

      expect(bot.provider).to eq('etsy')
      expect(bot.access_token).to eq('token1')
      expect(bot.refresh_token).to eq('token2')
      expect(bot.expires_at).to eq(expires_at)
      expect(response).to redirect_to(admin_products_path)
    end
  end

  describe 'redirect_to_etsy_oauth' do
    it 'should craft a url for sending to etsy for oauth' do
      allow_any_instance_of(Admin::EtsyController).to receive(:create_pkce_challenge_codes).and_return('code_challenge')
      allow(SecureRandom).to receive(:hex).with(5).and_return('state')
      session[:etsy_code_verifier] = 'etsy_code_verifier'

      get :redirect_to_etsy_oauth, params: {}

      expect(response).to redirect_to('https://www.etsy.com/oauth/connect?response_type=code&redirect_uri=http://localhost:3000/etsy/callback&scope=listings_r%20transactions_r%20listings_w%20listings_d&client_id=fake&state=state&code_challenge=code_challenge&code_challenge_method=S256')
    end
  end
end
