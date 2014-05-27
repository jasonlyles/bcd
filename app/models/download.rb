class Download < ActiveRecord::Base
  belongs_to :user
  belongs_to :products

  attr_accessible :product_id, :user_id, :count, :remaining, :download_token

  def increment_download_count(current_user,product_id,token=nil)
    if token.blank?
      #download = Download.find_or_create_by_user_id_and_product_id(current_user.id,product_id)
      download = Download.find_or_create_by(user_id: current_user.id, product_id: product_id)
    else
      download = Download.find_by_user_id_and_download_token(current_user.id,token)
    end
    #if download.count < MAX_DOWNLOADS
      download.count += 1
      download.save
    #end
  end

  def decrement_remaining_downloads(current_user,product_id,token=nil)
    if token.blank?
      #download = Download.find_or_create_by_user_id_and_product_id(current_user.id,product_id)
      download = Download.find_or_create_by(user_id: current_user.id, product_id: product_id)
    else
      download = Download.find_by_user_id_and_download_token(current_user.id,token)
    end
    if download.remaining > 0
      download.remaining -= 1
      download.save
    end
  end

  def self.update_download_counts(current_user,product_id,token=nil)
    if token.blank?
      #download = Download.find_or_create_by_user_id_and_product_id(current_user.id,product_id)
      download = Download.find_or_create_by(user_id: current_user.id, product_id: product_id)
    else
      download = Download.find_by_user_id_and_download_token(current_user.id,token)
    end
    download.count += 1
    download.remaining -= 1 if download.remaining > 0
    download.save
  end

  def self.add_download_to_user_and_model(user,model_id)
    download = Download.find_by_user_id_and_product_id(user.id,model_id)
    if download.remaining < MAX_DOWNLOADS
      download.remaining += 1
      download.save
    else
      download = nil
    end
    download
  end

  def self.update_all_users_who_have_downloaded_at_least_once(product_id)
    downloads = Download.where(["product_id = ? and count > 0",product_id])
    users = []
    downloads.each do |download|
      download.remaining += 1
      download.save
      users << download.user
    end
    #return an array of affected users, and their email preference
    users
  end
end
