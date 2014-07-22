class ContactMailer < AsyncMailer
  default from: "Brick City Depot <no-reply@brickcitydepot.com>"
  default to: EmailConfig.config.contact
  layout 'admin_email'

  def new_contact_email(name, email, body)
    @host = Rails.application.config.web_host
    @email = email
    @name = name
    @body = body

    mail(:reply_to => @email, :subject => "New Contact Form")
  end

  def queue_name
    "mailer"
  end

end

#:nocov:
if Rails.env.development?
  class ContactMailer::Preview < MailView
    def new_contact_email
      email = Email.new(name: 'Bob Smith', body: 'I like Lego', email_address: 'test@test.com')
      ContactMailer.new_contact_email(email.name, email.email_address, email.body)
    end
  end
end
#:nocov: