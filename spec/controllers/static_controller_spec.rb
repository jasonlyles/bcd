require 'spec_helper'

describe StaticController do
  before do
    @product_type = FactoryGirl.create(:product_type)
  end

  describe "GET 'index'" do
    it 'should be successful' do
      get 'index'
      expect(response).to be_success
    end
  end

  describe 'GET contact' do
    it 'should get contact' do
      get 'contact'
      expect(response).to be_success
    end
  end

  describe 'GET maintenance' do
    context 'maintenance is completed' do
      it 'should redirect to the home page' do
        @switch = FactoryGirl.create(:switch, switch_on: false)
        get 'maintenance'

        expect(flash[:notice]).to eq('Done with maintenance!')
        expect(response).to redirect_to('/')
      end
    end

    context 'maintenance is not yet complete' do
      it 'should render the maintenance page' do
        @switch = FactoryGirl.create(:switch, switch_on: true)
        get 'maintenance'

        expect(response).to be_success
      end
    end
  end

  describe 'POST send_contact_email' do
    it 'should send a contact email if email has valid params' do
      post 'send_contact_email', email: { name: 'Charlie Brown', email_address: 'charlie_brown@peanuts.com', body: 'I have too much money. Please help.' }

      expect(response).to redirect_to('/contact')
      expect(flash[:notice]).to eq("Thanks for your email. We'll get back with you shortly.")
    end

    it 'should not send a contact email if email has invalid params' do
      post 'send_contact_email', email: { name: '', email_address: 'blah', body: 'I have too much money. Please help.' }

      expect(flash[:alert]).to eq('Uh oh. Look below to see what you need to fix.')
      expect(response).to render_template('contact')
    end
  end

  describe 'legacy routes' do
    it 'should get legacy_name_signs' do
      get 'legacy_name_signs'
      expect(flash[:notice]).to eq("We don't currently have a Name Signs page. Please check back for an update soon.")
    end

    it 'should get legacy_custom_letters' do
      get 'legacy_custom_letters'
      expect(flash[:notice]).to eq("We don't currently have a Custom Letters page. Please check back for an update soon.")
    end

    it 'should get legacy_lego_prints' do
      get 'legacy_lego_prints'
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("We don't currently have a Lego Prints page. Please check back for an update soon.")
    end

    it 'should get legacy_books' do
      get 'legacy_books'
      expect(response).to render_template('books')
    end

    it 'should get legacy_instruction_sample' do
      get 'legacy_instruction_sample'
      expect(response).to render_template('instruction_sample')
    end

    it 'should get legacy_menswear_instructions' do
      cat = FactoryGirl.create(:category)
      subcat = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product, product_code: 'CB027')
      get 'legacy_menswear_instructions'
      expect(response).to redirect_to controller: :store, action: :product_details, product_code: 'CB027', product_name: 'colonial_revival_house'
    end

    it 'should get legacy_archfirm_instructions' do
      cat = FactoryGirl.create(:category)
      subcat = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product, product_code: 'CB028')
      get 'legacy_archfirm_instructions'
      expect(response).to redirect_to controller: :store, action: :product_details, product_code: 'CB028', product_name: 'colonial_revival_house'
    end

    it 'should get legacy_speakeasy_instructions' do
      cat = FactoryGirl.create(:category)
      subcat = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product, product_code: 'CB029')
      get 'legacy_speakeasy_instructions'
      expect(response).to redirect_to controller: :store, action: :product_details, product_code: 'CB029', product_name: 'colonial_revival_house'
    end

    it 'should get legacy_logo_theme_sign' do
      get 'legacy_logo_theme_sign'
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("We don't currently have a Lego Logo Theme Sign page. Please check back for an update soon.")
    end

    it 'should get legacy_city_theme_sign' do
      get 'legacy_city_theme_sign'
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("We don't currently have a City Theme Sign page. Please check back for an update soon.")
    end

    it 'should get legacy_friends_theme_sign' do
      get 'legacy_friends_theme_sign'
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("We don't currently have a Friends Theme Sign page. Please check back for an update soon.")
    end

    it 'should get legacy_star_wars_theme_sign' do
      get 'legacy_star_wars_theme_sign'
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("We don't currently have a Star Wars Theme Sign page. Please check back for an update soon.")
    end

    it 'should get legacy_sales_deals' do
      get 'legacy_sales_deals'
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("We don't currently have a Sales/Deals page. Please check back for an update soon.")
    end

    it 'should get legacy_google_hosted_service' do
      get 'legacy_google_hosted_service'
      expect(response).to render_template('google_hosted_service')
    end

    it 'should get legacy_commissions' do
      get 'legacy_commissions'
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("We don't currently have a Commissions page. Please check back for an update soon.")
    end

    it 'should get legacy_gallery' do
      get 'legacy_gallery'
      expect(response).to redirect_to('/')
      expect(flash[:notice]).to eq("We don't currently have a Gallery page. Please check back for an update soon.")
    end

    it 'should get legacy_instructions' do
      get 'legacy_instructions'
      expect(response).to redirect_to('/store/instructions')
    end

    it 'should get legacy_contact' do
      get 'legacy_contact'
      expect(response).to render_template('contact')
    end

    it 'should get legacy_city_category' do
      get 'legacy_city_category'
      expect(response).to redirect_to('/store/products/Instructions/City')
    end

    it 'should get legacy_winter_village_category' do
      get 'legacy_winter_village_category'
      expect(response).to redirect_to('/store/products/Instructions/Winter%20Village')
    end

    it 'should get legacy_military_category' do
      get 'legacy_military_category'
      expect(response).to redirect_to('/store/products/Instructions/Military')
    end

    it 'should get legacy_castle_category' do
      get 'legacy_castle_category'
      expect(response).to redirect_to('/store/products/Instructions/Other')
    end

    it 'should get legacy_train_category' do
      get 'legacy_train_category'
      expect(response).to redirect_to('/store/products/Instructions/Train')
    end
  end
end
