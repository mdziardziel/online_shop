class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV['BASIC_AUTH_LOGIN'], password: ENV['BASIC_AUTH_PASSWORD'], unless: :basic_auth_disabled

  helper_method :categories

  before_action :back_to_cart

  private
  
  def categories
    Product.kept.pluck(:category).sort.uniq
  end

  def basic_auth_disabled
    controller_name == 'payments' && action_name == 'provider_notify'
  end

  def back_to_cart
    return unless request.referer == 'https://merch-prod.snd.payu.com/simulator/spring/web/blikweb/transaction/transaction_init/auth'
    return if cookies['last_order_token'].nil?

    redirect_to order_path(id: cookies['last_order_token'])
    return
  end
end
