require 'spec_helper'

describe StaticController do
  describe 'routing' do
    it 'recognizes and generates googlehostedservice.html' do
      expect({ get: 'googlehostedservice.html' }).to route_to(controller: 'static', action: 'google_hosted_service', format: 'html')
    end

    it 'recognizes and generates books.html' do
      expect({ get: 'books.html' }).to route_to(controller: 'static', action: 'books', format: 'html')
    end

    it 'recognizes and generates #index' do
      expect({ get: '/' }).to route_to(controller: 'static', action: 'index')
    end

    it 'recognizes and generates #contact' do
      expect({ get: '/contact' }).to route_to(controller: 'static', action: 'contact')
    end

    it 'recognizes and generates #faq' do
      expect({ get: '/faq' }).to route_to(controller: 'static', action: 'faq')
    end

    it 'recognizes and generates #privacy_policy' do
      expect({ get: '/privacy_policy' }).to route_to(controller: 'static', action: 'privacy_policy')
    end

    it 'recognizes and generates #terms_of_service' do
      expect({ get: '/terms_of_service' }).to route_to(controller: 'static', action: 'terms_of_service')
    end
  end
end
