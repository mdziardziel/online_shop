class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV['BASIC_AUTH_LOGIN'], password: ENV['BASIC_AUTH_PASSWORD']

  helper_method :categories

  private
  
  def categories
    Product.kept.pluck(:category).uniq
  end
end
