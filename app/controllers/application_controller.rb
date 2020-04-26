class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV['BASIC_AUTH_LOGIN'], password: ENV['BASIC_AUTH_PASSWORD'], unless: :basic_auth_disabled

  helper_method :categories

  private
  
  def categories
    Product.kept.pluck(:category).uniq
  end

  def basic_auth_disabled
    controller_name == 'payments' && action_name == 'provider_notify'
  end
end
