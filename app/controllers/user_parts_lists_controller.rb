class UserPartsListsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :find_cart

  def update
    @user_parts_list = UserPartsList.find_or_create_by(parts_list_id: params[:id], user_id: current_user.id)
    @user_parts_list.values = params[:values]
    if @user_parts_list.save
      flash[:notice] = 'Parts List saved!'
      render json: '{}', status: :ok
    else
      begin
        ExceptionNotifier.notify_exception(StandardError.new, env: request.env, data: { message: "Parts List ID: #{@user_parts_list.parts_list_id}, User ID: #{@user_parts_list.user_id} Could not update users parts list" })
      ensure
        flash[:alert] = 'Sorry. There was a problem saving your parts list. We are looking into it.'
        render json: '{}', status: :unprocessable_entity
      end
    end
  end
end
