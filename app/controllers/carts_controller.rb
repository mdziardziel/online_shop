class CartsController < ApplicationController
  # GET /carts
  def index
    cart
  end

  private

  # prepares cart
  def cart
    cart_hash = JSON.parse(cookies['cart'].presence || '{}')
    cart_tmp = cart_hash.map { |id, quantity| [Product.find(id), quantity.to_i] }
    @cart ||= cart_tmp.each_with_object([]) { |cart, arr| arr <<  cart if cart.second > 0 }
  end
end
