# frozen_string_literal: true

class Admin::ThirdPartyOrdersController < AdminController
  # GET /third_party_orders/new
  def new
    @form = ThirdPartyOrderForm.new
    @products = Product.where(ready_for_public: true).instructions.order('category_id').order('product_code')
  end

  # POST /third_party_orders
  def create
    @form = ThirdPartyOrderForm.new(create_form_params)

    if @form.submit
      @order = @form.order
      redirect_to([:admin, @order], notice: 'Order was successfully created.')
    else
      @products = Product.where(ready_for_public: true).instructions.order('category_id').order('product_code')
      flash[:alert] = 'Order was NOT created'
      render 'new'
    end
  end

  private

  def create_form_params
    params.require(:third_party_order_form).permit(:third_party_order_id, :email, :source, product_ids: [])
  end
end
