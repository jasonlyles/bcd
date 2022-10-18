class PartsListsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :find_cart

  def show
    if current_user.has_access_to_parts_list?(params[:id])
      @parts_list = PartsList.find(params[:id])
      # It's ok for user_parts_list to be nil.
      user_parts_list = UserPartsList.where(user_id: current_user, parts_list_id: @parts_list.id).first
      @user_parts_list = if user_parts_list.present?
                           user_parts_list.values
                         else
                           '{}'
                         end
      @lots = @parts_list.lots.includes(element: [:color, :part]).order("parts.name ASC, colors.bl_name ASC")
    else
      flash[:alert] = "Sorry, you don't have access to this parts list. If you think this is an error, please contact us through the contact form."
      redirect_to :root
    end
  end
end
