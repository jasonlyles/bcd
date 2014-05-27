class UpdateMailer < ActionMailer::Base
  default :from => "no-reply@brickcitydepot.com"

  def updated_instructions(user, model, message)
    @host = Rails.application.config.web_host
    @user = user
    @model = model
    @message = message
    mail(:to => @user.email, :subject => "Instructions for #{@model.product_code} #{@model.name} have been updated")
  end
end
