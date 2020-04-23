class CartsController < ActionController::API 
  include ActionController::Cookies

  def add_product
    cart = cookies['cart'].present? ? JSON.parse(cookies['cart']) : {}
    cart[product_id] = cart[product_id].to_i + 1
    cookies['cart'] = cart.to_json
  end

  private

  def product_id
    params[:product_id]
  end
end
