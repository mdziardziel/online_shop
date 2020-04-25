class ApplicationController < ActionController::Base
  helper_method :categories

  private
  
  def categories
    Product.kept.pluck(:category).uniq
  end
end
