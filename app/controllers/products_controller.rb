class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  # GET /products
  def index
    @products = Product.kept.order(:name)
    @products = @products.where(category: params[:category]) if  params[:category].present?
  end

  # GET /products/1
  def show
  end

  private
    # ustawia produkt
    def set_product
      @product = Product.find(params[:id])
    end
end
