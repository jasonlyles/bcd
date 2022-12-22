# frozen_string_literal: true

class UserPartsListsController < ApplicationController
  before_action :authenticate_user!, unless: -> { is_valid_guest? }
  skip_before_action :find_cart

  def update
    user = find_user
    if user.blank?
      begin
        ExceptionNotifier.notify_exception(StandardError.new, env: request.env, data: { message: "Parts List ID: #{params[:id]}, Could not find user. session[:guest_user_id] = '#{session[:guest_user_id]}'" })
      ensure
        render json: 'Sorry. There was a problem saving your parts list. We are looking into it.', status: :unprocessable_entity
      end
    else
      @user_parts_list = UserPartsList.find_or_create_by(parts_list_id: params[:id], user_id: user.id)
      @user_parts_list.values = params[:values]
      if @user_parts_list.save
        flash[:notice] = 'Parts List saved!'
        render json: '{}', status: :ok
      else
        begin
          ExceptionNotifier.notify_exception(StandardError.new, env: request.env, data: { message: "Parts List ID: #{@user_parts_list.parts_list_id}, User ID: #{@user_parts_list.user_id} Could not update users parts list" })
        ensure
          render json: 'Sorry. There was a problem saving your parts list. We are looking into it.', status: :unprocessable_entity
        end
      end
    end
  end

  private

  def is_valid_guest?
    session[:guest_user_id].present? ? User.find(session[:guest_user_id]).present? : false
  end

  def find_user
    current_user ? current_user : User.find(session[:guest_user_id])
  end
end
