# frozen_string_literal: true

class Admin::OrdersController < AdminController
  before_action :assign_order, only: %i[show]

  # GET /orders
  def index
    @q = Order.ransack(params[:q])
    @orders = @q.result.includes(:user, :line_items).page(params[:page]).per(20)
  end

  # GET /orders/1
  def show
    @third_party_receipt = @order.third_party_receipt
  end

  def complete_order
    @order = Order.find(params[:id])
    @order.status = 'COMPLETED'
    @order.save
    flash[:notice] = 'Order was marked COMPLETED'
    redirect_back(fallback_location: '/admin/orders')
  end

  private

  def assign_order
    @order = Order.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def order_params
    params.require(:order).permit(:test)
  end
end
