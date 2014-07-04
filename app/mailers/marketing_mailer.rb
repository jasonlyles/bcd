class MarketingMailer < ActionMailer::Base
  default :from => "Brick City Depot <no-reply@brickcitydepot.com>"
  layout 'base_email'

  def new_product_notification(product, product_type, image_url, user, message=nil)
    @host = Rails.application.config.web_host
    @product = product
    @product_type = product_type
    @image = image_url
    @message = message
    @user = user
    mail(to: @user.email, subject: "New Product!")
  end

  #:nocov:
  if Rails.env.development?
    class MarketingMailer::Preview < MailView
      def new_product_notification
        @user = User.first
        @product = Product.first

        MarketingMailer.new_product_notification(@product, @product.product_type.name, @product.main_image.medium,
                                                 @user, "Marketing mumbo-jumbo...")
      end
    end
  end
  #:nocov:
end
