require 'spec_helper'

describe PartsListUpdateNotificationJob do
  before do
    @product = FactoryBot.create(:product_with_associations)
  end

  describe 'perform' do
    context 'user has purchased a relevant set of instructions' do
      it 'should NOT email a user if they are cancelled' do
        user = FactoryBot.create(:user, account_status: 'C', email_preference: 2)
        order = FactoryBot.create(:order_with_line_items, user_id: user.id)

        expect(UpdateMailer).to_not receive(:updated_parts_lists)
        PartsListUpdateNotificationJob.perform_sync([@product.id], 'Just an update')
      end

      it 'should NOT email a user if they do not want this type of email' do
        user = FactoryBot.create(:user, account_status: 'A', email_preference: 0)
        order = FactoryBot.create(:order_with_line_items, user_id: user.id)

        expect(UpdateMailer).to_not receive(:updated_parts_lists)
        PartsListUpdateNotificationJob.perform_sync([@product.id], 'Just an update')
      end

      it 'should email a user if they are not cancelled and want to receive this type of email' do
        user = FactoryBot.create(:user, account_status: 'A', email_preference: 2)
        order = FactoryBot.create(:order_with_line_items, user_id: user.id)

        expect(UpdateMailer).to receive(:updated_parts_lists).with(user.id, ['CB001 Colonial Revival House'], 'Just an update')
        PartsListUpdateNotificationJob.perform_sync([@product.id], 'Just an update')
      end
    end

    context 'user has not purchased a relevant set of instructions' do
      it 'should not email this user' do
        user = FactoryBot.create(:user, account_status: 'A', email_preference: 2)

        expect(UpdateMailer).to_not receive(:updated_parts_lists)
        PartsListUpdateNotificationJob.perform_sync([@product.id], 'Just an update')
      end
    end

    context 'something goes wrong' do
      it 'should log the error and send a notice to dev' do
        user = FactoryBot.create(:user, account_status: 'A', email_preference: 2)
        order = FactoryBot.create(:order_with_line_items, user_id: user.id)

        allow(UpdateMailer).to receive(:updated_parts_lists).and_raise(StandardError)
        expect(ExceptionNotifier).to receive(:notify_exception).with(StandardError, { data: { message: 'PartsListUpdateNotificationJob could not send an email to user 1 about products 1' } })
        PartsListUpdateNotificationJob.perform_sync([@product.id], 'Just an update')
      end
    end
  end
end
