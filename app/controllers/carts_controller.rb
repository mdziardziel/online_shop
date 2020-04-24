class CartsController < ApplicationController
  MAXIMUM_PRODUCTS_PER_ORDER = 15
  def index
    cart
  end

  private

  def cart
    cart_hash = JSON.parse(cookies['cart'] || '{}')
    cart_tmp = cart_hash.map { |id, quantity| [Product.find(id), quantity] }
    @cart ||= cart_tmp.each_with_object([]) { |cart, arr| arr <<  cart if cart.second > 0 }
  end
end
