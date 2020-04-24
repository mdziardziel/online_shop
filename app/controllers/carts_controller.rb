class CartsController < ApplicationController
  MAXIMUM_PRODUCTS_PER_ORDER = 15
  def index
    cart
  end

  private

  def cart
    cart_hash = JSON.parse(cookies['cart'] || '{}')
    @cart ||= cart_hash.map { |id, quantity| [Product.find(id), quantity] }
  end
end
