require 'spec_helper'

describe PartsListsController do
  before do
    @user ||= FactoryGirl.create(:user)
    sign_in @user

    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcat = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product)
    @parts_list = FactoryGirl.create(:parts_list, name: 'fake', product_id: @product.id, bricklink_xml: '<XML>fake</XML', original_filename: 'fake.xml')
  end

  describe 'GET show' do
    context 'with a user that has access to the parts lists product' do
      context 'with an existing user parts list' do
        it 'should return the user parts list values' do
          @user_parts_list = FactoryGirl.create(:user_parts_list, user_id: @user.id, parts_list_id: @parts_list.id, values: "{fake: 'json'}")
          @order = FactoryGirl.create(:order_with_line_items)
          get :show, id: @parts_list.id

          expect(assigns(:user_parts_list)).to eq("{fake: 'json'}")
        end
      end

      context 'without an existing user parts list' do
        it 'should return empty json' do
          @order = FactoryGirl.create(:order_with_line_items)
          get :show, id: @parts_list.id

          expect(assigns(:user_parts_list)).to eq('{}')
        end
      end
    end

    context 'with a user that does not have access to the parts list product' do
      it 'should let the user know they do not have access' do
        get :show, id: @parts_list.id

        expect(flash[:alert]).to eq("Sorry, you don't have access to this parts list. If you think this is an error, please contact us through the contact form.")
        expect(response).to redirect_to('/')
      end
    end
  end
end
