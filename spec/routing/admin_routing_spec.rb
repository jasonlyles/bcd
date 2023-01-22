require 'spec_helper'

describe AdminController do
  describe 'routing' do
    it 'recognizes and generates #admin_profile' do
      expect({ get: '/woofay/1/admin_profile' }).to route_to(controller: 'admin', action: 'admin_profile', id: '1')
    end

    it 'recognizes and generates #update_admin_profile' do
      expect({ patch: '/woofay/1/update_admin_profile' }).to route_to(controller: 'admin', action: 'update_admin_profile', id: '1')
    end

    it 'recognizes and generates #update_downloads_for_users' do
      expect({ post: '/woofay/update_downloads_for_users' }).to route_to(controller: 'admin', action: 'update_downloads_for_users')
    end

    it 'recognizes and generates #update_users_download_counts' do
      expect({ get: '/update_users_download_counts' }).to route_to(controller: 'admin', action: 'update_users_download_counts')
    end
  end
end
