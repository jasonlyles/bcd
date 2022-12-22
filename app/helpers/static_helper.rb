# frozen_string_literal: true

module StaticHelper
  def downloads_remaining(product_id)
    download = Download.find_by_user_id_and_product_id(current_user.id, product_id)
    download.blank? ? MAX_DOWNLOADS : download.remaining
  end
end
