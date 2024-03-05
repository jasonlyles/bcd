require 'spec_helper'

describe Admin::ThirdPartyOrdersController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
    @product = FactoryBot.create(:product_with_associations)
  end

  before(:each) do |example|
    sign_in @radmin unless example.metadata[:skip_before]
  end

  describe 'create' do
    context 'happy path' do
      it 'should redirect to the order page' do
        expect {
          expect {
            expect {
              post :create, params: {
                third_party_order_form: {
                  third_party_order_id: '123',
                  email: 'lylesjt@lyles.mil',
                  source: 'bricklink',
                  product_ids: [@product.id]
                }
              }
            }.to change(Order, :count).by(1)
          }.to change(ThirdPartyReceipt, :count).by(1)
        }.to change(User, :count).by(1)

        # check the created user
        user = User.last
        expect(user.email).to eq('lylesjt@lyles.mil')
        expect(user.source).to eq('bricklink')

        # check the created order
        order = user.orders.last
        expect(order.status).to eq('COMPLETED')
        expect(order.source).to eq('bricklink')
        expect(order.third_party_order_identifier).to eq('123')
        expect(order.confirmation_email_sent).to eq(true)

        # check the created third party receipt
        tpr = order.third_party_receipt
        expect(tpr.source).to eq('bricklink')
        expect(tpr.third_party_receipt_identifier).to eq('123')
        expect(tpr.third_party_order_status).to eq('Completed')
        expect(tpr.third_party_is_paid).to eq(true)
        expect(tpr.raw_response_body).to eq('{}')

        expect(response).to redirect_to(admin_order_path(order.id))
      end
    end

    context 'form fails validation' do
      it 'should rerender the form' do
        # Not passing in a user email to trigger form validation fail
        expect {
          expect {
            expect {
              post :create, params: {
                third_party_order_form: {
                  third_party_order_id: '123',
                  source: 'bricklink',
                  product_ids: [@product.id]
                }
              }
            }.to_not change(Order, :count)
          }.to_not change(ThirdPartyReceipt, :count)
        }.to_not change(User, :count)

        expect(assigns(:form).errors.first.attribute).to eq(:email)
        expect(assigns(:form).errors.first.type).to eq(:blank)

        expect(flash[:alert]).to eq('Order was NOT created')
        expect(response).to render_template('new')
      end
    end
  end
end
