# frozen_string_literal: true

class MarketingMailer < ActionMailer::Base
  default from: 'Brick City Depot <sales@brickcitydepot.com>'
  layout 'base_email'

  def new_product_notification(product, product_type, image_url, user, message = nil)
    @host = Rails.application.config.web_host
    @product = Oj.load(product)
    @product_type = product_type
    @image = image_url
    @message = message
    @user = Oj.load(user)
    mail(to: @user['email'], subject: 'New Product!')
  end

  def new_marketing_notification(email_campaign, user)
    @host = Rails.application.config.web_host
    @email_campaign = Oj.load(email_campaign)
    @user = Oj.load(user)
    mail(to: @user['email'], subject: @email_campaign['subject'])
  end

  # :nocov:
  def queue_name
    'batchmailer'
  end
  # :nocov:
end

# :nocov:
if Rails.env.development?
  class MarketingMailer::Preview < MailView
    def new_product_notification
      @user = User.first.attributes.to_json
      @product = Product.first

      MarketingMailer.new_product_notification(@product.attributes.to_json, @product.product_type.name, @product.main_image&.medium,
                                               @user, 'Marketing mumbo-jumbo...')
    end

    def new_marketing_notification
      @user = User.first.attributes.to_json
      @email_campaign = EmailCampaign.first
      MarketingMailer.new_marketing_notification(@email_campaign.attributes.to_json, @user)
    end
  end
end
# :nocov:
