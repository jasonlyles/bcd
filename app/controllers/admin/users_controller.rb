# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :assign_user, only: %i[show change_user_status become reset_users_downloads]

  # GET /users
  def index
    @q = User.ransack(params[:q])
    @users = @q.result.includes(orders: :line_items).page(params[:page]).per(20)
  end

  # GET /users/1
  def show
    @products = Product.where(ready_for_public: true).instructions.order('category_id').order('product_code')
  end

  def change_user_status
    @user.update(account_status: params[:user][:account_status])
    @products = Product.where(ready_for_public: true).instructions.order('category_id').order('product_code')
    respond_to(&:js)
  end

  def become
    return unless current_radmin

    sign_in(:user, @user)
    redirect_to root_path
  end

  def reset_users_downloads
    result = Download.reset_downloads(@user, params['download']['product_id'])
    flash[:notice] = if result.blank?
                       'Resetting downloads unnecessary'
                     else
                       "Downloads reset for #{@user.email}"
                     end
    redirect_back(fallback_location: '/admin/users')
  end

  private

  def assign_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:test)
  end
end
