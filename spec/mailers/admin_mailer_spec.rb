require 'spec_helper'

describe AdminMailer do
  describe 'active_notifications_email' do
    it 'should let admins know there are active notifications' do
      @mail = AdminMailer.active_notifications_email(40)
      expect(@mail.subject).to eq('40 Active Notifications on Brick City Depot')
      expect(@mail.to).to eq(['lylesjt@gmail.com'])
      expect(@mail.from).to eq(['sales@brickcitydepot.com'])
      @mail.body.parts.each do |part|
        expect(part.body.to_s).to match('/admin/notifications')
      end
    end
  end
end
