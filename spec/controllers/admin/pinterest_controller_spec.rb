require 'spec_helper'

describe Admin::PinterestController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
    @product = FactoryBot.create(:product_with_associations)
  end

  before(:each) do |example|
    sign_in @radmin unless example.metadata[:skip_before]
  end

  describe 'callback' do
    context 'the session state variable does not matches the state param' do
      it 'should raise an error' do
        session[:pinterest_state] = 'abc'

        expect {
          get :callback, params: { code: '1234', state: 'tampered_state' }
        }.to raise_error(IncorrectPinterestState)
      end
    end

    context 'the session state variable matches the state param' do
      it 'should store access tokens' do
        session[:pinterest_state] = 'abc'
        expires_at = Time.now + 1.hour
        allow(Pinterest::Api::AccessToken).to receive(:get).and_return({ access_token: 'token1', refresh_token: 'token2', expires_at: })

        get :callback, params: { code: '1234', state: 'abc' }

        bot = BackendOauthToken.last

        expect(bot.provider).to eq('pinterest')
        expect(bot.access_token).to eq('token1')
        expect(bot.refresh_token).to eq('token2')
        expect(bot.expires_at).to eq(expires_at)
        expect(response).to redirect_to(admin_products_path)
      end
    end
  end

  describe 'redirect_to_pinterest_oauth' do
    it 'should craft a url for sending to pinterest for oauth' do
      allow(SecureRandom).to receive(:hex).with(5).and_return('state')

      get :redirect_to_pinterest_oauth, params: {}

      expect(response).to redirect_to('https://www.pinterest.com/oauth?response_type=code&redirect_uri=http://localhost:3000/pinterest/callback&scope=boards:read,boards:write,pins:read,pins:write&client_id=5&state=state')
    end
  end
end
