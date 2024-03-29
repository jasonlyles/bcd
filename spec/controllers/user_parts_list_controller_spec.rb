require 'spec_helper'

describe UserPartsListsController do
  before do
    @user ||= FactoryBot.create(:user)
    sign_in @user
    @product_type = FactoryBot.create(:product_type)
    @category = FactoryBot.create(:category)
    @subcategory = FactoryBot.create(:subcategory)
    @product = FactoryBot.create(:product, id: 2)
    @parts_list = FactoryBot.create(:parts_list, name: 'fake', product_id: 2, bricklink_xml: '<XML>fake</XML', original_filename: 'fake.xml')
    @user_parts_list = FactoryBot.create(:user_parts_list, user_id: @user.id, parts_list_id: @parts_list.id)
  end

  describe 'PUT update' do
    context 'with valid params' do
      it 'should update the active users parts list' do
        put :update, params: { id: @parts_list.id, values: "{\"4592c02_86\":\"0\",\"4095_86\":\"2\",\"2436_86\":\"3\"}" }
        @user_parts_list.reload

        expect(flash[:notice]).to eq('Parts List saved!')
        expect(@user_parts_list.values).to eq("{\"4592c02_86\":\"0\",\"4095_86\":\"2\",\"2436_86\":\"3\"}")
        expect(response.body).to eq('{}')
        expect(response.code).to eq('200')
      end
    end

    context 'with invalid params' do
      it 'should not update the active users parts list' do
        allow_any_instance_of(UserPartsList).to receive(:save).and_return(false)
        put :update, params: { id: @parts_list.id, values: "{\"4592c02_86\":\"0\",\"4095_86\":\"2\",\"2436_86\":\"3\"}" }
        @user_parts_list.reload

        expect(@user_parts_list.values).to be_nil
        expect(response.body).to eq('Sorry. There was a problem saving your parts list. We are looking into it.')
        expect(response.code).to eq('422')
      end

      it 'send an error email and let the user know there was a problem' do
        allow_any_instance_of(UserPartsList).to receive(:save).and_return(false)
        expect(ExceptionNotifier).to receive(:notify_exception).with(StandardError.new, env: request.env, data: { message: "Parts List ID: #{@parts_list.id}, User ID: #{@user.id} Could not update users parts list" })
        put :update, params: { id: @parts_list.id, values: "{\"4592c02_86\":\"0\",\"4095_86\":\"2\",\"2436_86\":\"3\"}" }
        @user_parts_list.reload

        expect(response.body).to eq('Sorry. There was a problem saving your parts list. We are looking into it.')
      end
    end
  end
end
