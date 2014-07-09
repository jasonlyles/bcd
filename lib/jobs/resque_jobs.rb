module ResqueJobs

  #This method just returns the value set in one of the classes in this module. This is a way of
  # making a queue method available for TempAgency, which uses after hooks to hire and fire workers on Heroku
  def queue
    @queue
  end

  class NewProductNotification
    extend TempAgency
    extend ResqueJobs
    @queue = :batchmailer

    def self.perform(product_id, message=nil)
      users = User.who_get_all_emails
      product = Product.find(product_id)
      product_type = product.product_type.name
      image_url = product.main_image.medium
      recipient = Struct.new(:email, :guid, :unsubscribe_token)
      users.each do |user|
        MarketingMailer.new_product_notification(product, product_type, image_url, recipient.new(user[0],user[1],user[2]), message).deliver
        #Trying a simple throttle to make sure I'm not sending more than 5 emails/second so I don't run afoul
        # of my Amazon SES limits
        sleep 0.2
      end
    end
  end
end