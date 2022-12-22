require 'spec_helper'

describe PartsListUpdateNotificationJob do
  before do
    @product = FactoryGirl.create(:product_with_associations)
  end

  describe 'perform' do
    context 'user has purchased a relevant set of instructions' do
      it 'should NOT email a user if they are cancelled' do
        user = FactoryGirl.create(:user, account_status: 'C', email_preference: 2)
        order = FactoryGirl.create(:order_with_line_items, user_id: user.id)

        expect(UpdateMailer).to_not receive(:updated_parts_lists)
        PartsListUpdateNotificationJob.perform('product_ids' => [@product.id], 'message' => 'Just an update')
      end

      it 'should NOT email a user if they do not want this type of email' do
        user = FactoryGirl.create(:user, account_status: 'A', email_preference: 0)
        order = FactoryGirl.create(:order_with_line_items, user_id: user.id)

        expect(UpdateMailer).to_not receive(:updated_parts_lists)
        PartsListUpdateNotificationJob.perform('product_ids' => [@product.id], 'message' => 'Just an update')
      end

      it 'should email a user if they are not cancelled and want to receive this type of email' do
        user = FactoryGirl.create(:user, account_status: 'A', email_preference: 2)
        order = FactoryGirl.create(:order_with_line_items, user_id: user.id)

        expect(UpdateMailer).to receive(:updated_parts_lists).with(user.id, ["CB001 Colonial Revival House"], "Just an update")
        PartsListUpdateNotificationJob.perform('product_ids' => [@product.id], 'message' => 'Just an update')
      end
    end

    context 'user has not purchased a relevant set of instructions' do
      it 'should not email this user' do
        user = FactoryGirl.create(:user, account_status: 'A', email_preference: 2)

        expect(UpdateMailer).to_not receive(:updated_parts_lists)
        PartsListUpdateNotificationJob.perform('product_ids' => [@product.id], 'message' => 'Just an update')
      end
    end

    context 'something goes wrong' do
      it 'should log the error and send a notice to dev' do
        user = FactoryGirl.create(:user, account_status: 'A', email_preference: 2)
        order = FactoryGirl.create(:order_with_line_items, user_id: user.id)

        allow(UpdateMailer).to receive(:updated_parts_lists).and_raise(StandardError)
        expect(ExceptionNotifier).to receive(:notify_exception).with(StandardError, { data: { message: 'PartsListUpdateNotificationJob could not send an email to user 1 about products 1' } })
        PartsListUpdateNotificationJob.perform('product_ids' => [@product.id], 'message' => 'Just an update')
      end
    end
  end
end
