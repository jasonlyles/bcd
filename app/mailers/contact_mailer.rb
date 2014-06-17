class ContactMailer < ActionMailer::Base
  default from: "no-reply@brickcitydepot.com"
  default to: EmailConfig.config.contact
  layout 'admin_email'

  def new_contact_email(email)
    @host = Rails.application.config.web_host
    @email = email

    mail(:from => email.email_address, :subject => "Brick City Depot contact form")
  end
end

#:nocov:
if Rails.env.development?
  class ContactMailer::Preview < MailView
    def new_contact_email
      @email = Email.new(name: 'Bob Smith', body: 'I like Lego', email_address: 'test@test.com')
      ContactMailer.new_contact_email(@email)
    end
  end
end
#:nocov: