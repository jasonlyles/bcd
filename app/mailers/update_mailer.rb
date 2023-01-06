# frozen_string_literal: true

class UpdateMailer < AsyncMailer
  default from: 'Brick City Depot <sales@brickcitydepot.com>'
  layout 'base_email'

  def updated_instructions(user_id, model_id, message)
    @host = Rails.application.config.web_host
    @user = User.find(user_id)
    @model = Product.find(model_id)
    @message = message
    @hide_unsubscribe = true

    mail(to: @user.email, subject: "Instructions for #{@model.product_code} #{@model.name} have been updated")
  end

  def updated_parts_lists(user_id, product_names, message)
    @host = Rails.application.config.web_host
    @user = User.find(user_id)
    @products = product_names
    @message = message
    @hide_unsubscribe = true

    mail(to: @user.email, subject: 'Parts lists for instructions you own have been updated')
  end

  # :nocov:
  def queue_name
    'batchmailer'
  end
  # :nocov:
end
# :nocov:
if Rails.env.development?
  class UpdateMailer::Preview < MailView
    def updated_instructions
      @user = User.first
      @model = Product.first
      message = 'It was broken, so we fixed it.'

      UpdateMailer.updated_instructions(@user.id, @model.id, message)
    end

    def updated_parts_lists
      @user = User.first
      @product_names = ['CB002 Colonial Revival House', 'CV001 Rollback Tow Truck']
      @message = 'We had to change part 4599, Tap 1 x 1 to 4599b, Tap 1 x 1 without Hole in Nozzle End'

      UpdateMailer.updated_parts_lists(@user.id, @product_names, @message)
    end
  end
end
# :nocov:
