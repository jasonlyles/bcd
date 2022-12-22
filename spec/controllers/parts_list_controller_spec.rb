require 'spec_helper'

describe PartsListsController do
  before do
    @product = FactoryGirl.create(:product_with_associations)
    @parts_list = FactoryGirl.create(:parts_list, name: 'fake', product_id: @product.id, bricklink_xml: '<XML>fake</XML', original_filename: 'fake.xml')
  end

  describe 'GET show' do
    context 'for authenticated users' do
      context 'with a user that has access to the parts lists product' do
        context 'with an existing user parts list' do
          it 'should return the user parts list values' do
            @user = FactoryGirl.create(:user)
            sign_in @user
            @user_parts_list = FactoryGirl.create(:user_parts_list, user_id: @user.id, parts_list_id: @parts_list.id, values: "{fake: 'json'}")
            @order = FactoryGirl.create(:order_with_line_items)
            get :show, params: { id: @parts_list.id }

            expect(assigns(:user_parts_list)).to eq("{fake: 'json'}")
          end
        end

        context 'without an existing user parts list' do
          it 'should return empty json' do
            @user = FactoryGirl.create(:user)
            sign_in @user
            @order = FactoryGirl.create(:order_with_line_items)
            get :show, params: { id: @parts_list.id }

            expect(assigns(:user_parts_list)).to eq('{}')
          end
        end
      end

      context 'with a user that does not have access to the parts list product' do
        it 'should let the user know they do not have access' do
          @user = FactoryGirl.create(:user)
          sign_in @user
          get :show, params: { id: @parts_list.id }

          expect(flash[:alert]).to eq("Sorry, you don't have access to this parts list. If you think this is an error, please contact us through the contact form.")
          expect(response).to redirect_to('/')
        end
      end
    end

    context 'for guest users' do
      context 'with a user that has access to the parts lists product' do
        context 'with an existing user parts list' do
          it 'should return the user parts list values' do
            @user = FactoryGirl.create(:user, account_status: 'G')
            @user_parts_list = FactoryGirl.create(:user_parts_list, user_id: @user.id, parts_list_id: @parts_list.id, values: "{fake: 'json'}")
            @order = FactoryGirl.create(:order_with_line_items)
            @download = FactoryGirl.create(:download, download_token: '1234', product_id: @parts_list.product_id, user_id: @user.id)

            get :show, params: { id: @parts_list.id, token: @download.download_token, user_guid: @user.guid }

            expect(assigns(:user_parts_list)).to eq("{fake: 'json'}")
          end
        end

        context 'without an existing user parts list' do
          it 'should return empty json' do
            @user = FactoryGirl.create(:user, account_status: 'G')
            @order = FactoryGirl.create(:order_with_line_items)
            @download = FactoryGirl.create(:download, download_token: '1234', product_id: @parts_list.product_id, user_id: @user.id)
            get :show, params: { id: @parts_list.id, token: @download.download_token, user_guid: @user.guid }

            expect(assigns(:user_parts_list)).to eq('{}')
          end
        end
      end

      context 'with a user that does not have access to the parts list product' do
        it 'should redirect the user to login' do
          @user = FactoryGirl.create(:user, account_status: 'G')
          get :show, params: { id: @parts_list.id, token: 'fake', user_guid: @user.guid }

          expect(flash[:alert]).to eq('You need to sign in or sign up before continuing.')
          expect(response).to redirect_to('/users/sign_in')
        end
      end
    end
  end
end
