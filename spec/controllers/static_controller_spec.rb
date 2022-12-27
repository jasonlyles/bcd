require 'spec_helper'

describe StaticController do
  before do
    @product_type = FactoryBot.create(:product_type)
  end

  describe "GET 'index'" do
    it 'should be successful' do
      get 'index'
      expect(response).to be_successful
    end
  end

  describe 'GET contact' do
    it 'should get contact' do
      get 'contact'
      expect(response).to be_successful
    end
  end

  describe 'GET maintenance' do
    context 'maintenance is completed' do
      it 'should redirect to the home page' do
        @switch = FactoryBot.create(:switch, switch_on: false)
        get 'maintenance'

        expect(flash[:notice]).to eq('Done with maintenance!')
        expect(response).to redirect_to('/')
      end
    end

    context 'maintenance is not yet complete' do
      it 'should render the maintenance page' do
        @switch = FactoryBot.create(:switch, switch_on: true)
        get 'maintenance'

        expect(response).to be_successful
      end
    end
  end

  describe 'POST send_contact_email' do
    it 'should send a contact email if email has valid params' do
      post 'send_contact_email', params: { email: { name: 'Charlie Brown', email_address: 'charlie_brown@peanuts.com', body: 'I have too much money. Please help.' } }

      expect(assigns(:email)).to_not be_nil
      expect(response).to redirect_to('/contact')
      expect(flash[:notice]).to eq("Thanks for your email. We'll get back with you shortly.")
    end

    it 'should not send a contact email if email has invalid params' do
      post 'send_contact_email', params: { email: { name: '', email_address: 'blah', body: 'I have too much money. Please help.' } }

      expect(flash[:alert]).to eq('Uh oh. Look below to see what you need to fix.')
      expect(response).to render_template('contact')
    end

    it 'should pretend to send a contact email if the honeypot is populated' do
      post 'send_contact_email', params: { email: { name: 'Charlie Brown', email_address: 'charlie_brown@peanuts.com', body: 'I have too much money. Please help.', contact_info: 'Gotcha' } }

      expect(assigns(:email)).to be_nil
      expect(response).to redirect_to('/contact')
      expect(flash[:notice]).to eq("Thanks for your email. We'll get back with you shortly.")
    end
  end

  it 'should get books' do
    get 'books'
    expect(response).to render_template('books')
  end

  it 'should get google_hosted_service' do
    get 'google_hosted_service'
    expect(response).to render_template('google_hosted_service')
  end
end
