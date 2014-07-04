class UpdateMailer < AsyncMailer
  default :from => "Brick City Depot <no-reply@brickcitydepot.com>"
  layout 'base_email'

  def updated_instructions(user_id, model_id, message)
    @host = Rails.application.config.web_host
    @user = User.find(user_id)
    @model = Product.find(model_id)
    @message = message
    @hide_unsubscribe = true

    mail(to: @user.email, subject: "Instructions for #{@model.product_code} #{@model.name} have been updated")
  end
end
#:nocov:
if Rails.env.development?
  class UpdateMailer::Preview < MailView
    def updated_instructions
      @user = User.first
      @model = Product.first
      message = "It was broken, so we fixed it."

      UpdateMailer.updated_instructions(@user.id, @model.id, message)
    end
  end
end
#:nocov: