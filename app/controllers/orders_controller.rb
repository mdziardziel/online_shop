class OrdersController < ApplicationController
  before_action :set_order, only: [:show]

  # GET /products/1
  # GET /products/1.json
  def show
  end

  def create
    products = Product.where(id: order_params.keys)
    total_amount = 0

    products_orders = order_params.to_unsafe_h.map do |product_id, quantity|
      product = products.find { |p| p.id.to_s == product_id }
      amount = product.price * quantity.to_i
      total_amount += amount
      { product_id: product.id, quantity: quantity, amount: amount }
    end

    @order = Order.new(products_orders_attributes: products_orders, amount: total_amount)

    result = false

    Order.transaction do
      @order.save!
      update_products_quantity

      result = true
    end

    if result
      cookies['cart'] = { value: nil, path: nil }
      cookies['last_order_token'] = { value: @order.token, path: nil }
      redirect_to order_path(id: @order.token)
    else
      flash[:error] = @order.errors.full_messages
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find_by(token: params[:id])
    end

    def order_params
      params.require(:products)
    end

    def update_products_quantity
      @order.products_orders.each do |po|
        product = po.product
        new_quantity = product.quantity - po.quantity
        product.update!(quantity: new_quantity)
      end
    end
end
