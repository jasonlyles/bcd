class ContactMailer < ActionMailer::Base
  default from: "no-reply@brickcitydepot.com"
  default to: EmailConfig.config.contact

  def new_contact_email(email)
    @host = Rails.application.config.action_mailer.default_url_options[:host] #This seems wrong, but I don't know what's right
    @email = email
    mail(:from => email.email_address, :subject => "Brick City Depot contact form")
  end
end
