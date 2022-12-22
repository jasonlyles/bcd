# frozen_string_literal: true

class PartsListsController < ApplicationController
  # find_parts_list needs to come before authenticate_user!
  before_action :find_parts_list
  before_action :authenticate_user!, unless: -> { valid_guest_token? }

  def show
    if access_to_parts_list?
      # It's ok for user_parts_list to be nil.
      user_parts_list = UserPartsList.where(user_id: @user, parts_list_id: @parts_list.id).first
      @user_parts_list = if user_parts_list.present?
                           user_parts_list.values
                         else
                           '{}'
                         end
      @lots = @parts_list.lots.includes(element: %i[color part]).order('parts.name ASC, colors.bl_name ASC')
    else
      flash[:alert] = 'Sorry, you don\'t have access to this parts list. If you think this is an error, please contact us through the contact form.'
      redirect_to :root
    end
  end

  private

  def find_parts_list
    @parts_list = PartsList.find(params[:id])
  end

  def access_to_parts_list?
    if current_user
      @user = current_user
      current_user.access_to_parts_list?(params[:id])
    else
      valid_guest_token?
    end
  end

  def valid_guest_token?
    # Look up user by guid to get user.id. Return if it doesn't exist
    @user = User.where(guid: params[:user_guid]).first
    return false if @user.blank?

    session[:guest_user_id] = @user.id
    # Then look up download by token, user.id and product id. If the record exists,
    # authentication will be bypassed and the user sent to the parts list.
    Download.where(download_token: params[:token], user_id: @user.id, product_id: @parts_list.product_id).present?
  end
end
