class Download < ActiveRecord::Base
  belongs_to :user
  belongs_to :product

  attr_accessible :product_id, :user_id, :count, :remaining, :download_token

  def self.update_download_counts(current_user, product_id, token = nil)
    if token.blank?
      download = Download.find_or_create_by(user_id: current_user.id, product_id: product_id)
    else
      download = Download.find_by_user_id_and_download_token(current_user.id, token)
    end
    download.count += 1
    download.remaining -= 1 if download.remaining > 0
    download.save
  end

  def self.add_download_to_user_and_model(user, model_id)
    download = Download.find_by_user_id_and_product_id(user.id, model_id)
    if download.remaining < MAX_DOWNLOADS
      download.remaining += 1
      download.save
    else
      download = nil
    end
    download
  end

  def self.update_all_users_who_have_downloaded_at_least_once(product_id)
    downloads = Download.where(['product_id = ? and count > 0', product_id])
    users = []
    downloads.each do |download|
      download.remaining += 1
      download.save
      # Don't return the user if the user doesn't want emails. The users being returned will be sent emails
      users << download.user unless download.user.email_preference == 'no_emails'
    end
    users
  end

  def restock
    self.remaining += MAX_DOWNLOADS
    save
    self
  end

  def reset!
    self.remaining = MAX_DOWNLOADS
    save
    self
  end

  def self.restock_for_order(order)
    items = order.get_digital_items
    items.each do |item|
      download = Download.find_by_user_id_and_product_id(order.user, item.product.id)
      # If the download record exists, user is trying to buy more downloads, so restock
      download.restock unless download.blank?
    end
  end
end
